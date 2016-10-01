#include <algorithm>
#include <cfloat>
#include <vector>

#include "caffe/common.hpp"
#include "caffe/layer.hpp"
#include "caffe/syncedmem.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/vision_layers.hpp"

namespace caffe {

using std::min;
using std::max;

template<typename Dtype>
void UnPoolingLayer<Dtype>::LayerSetUp(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    UnPoolingParameter unpool_param = this->layer_param_.unpooling_param();

    // kernel
    if (!unpool_param.has_kernel_size())
        LOG(FATAL)<< "there is no kernel size.";

    kernel_h_ = kernel_w_ = unpool_param.kernel_size();
    CHECK_GT(kernel_h_, 0)<< "Filter dimensions cannot be zero.";
    CHECK_GT(kernel_w_, 0)<< "Filter dimensions cannot be zero.";

    // pad
    if (unpool_param.has_pad())
        LOG(FATAL)<< "pad not supported.";

    pad_h_ = pad_w_ = 0;
    CHECK_EQ(pad_h_, 0)<< "currently, only zero padding is allowed.";
    CHECK_EQ(pad_w_, 0)<< "currently, only zero padding is allowed.";

    // stride
    if (unpool_param.has_stride()) {
        stride_h_ = stride_w_ = unpool_param.stride();
    } else {
        stride_h_ = stride_w_ = 1;
    }

    unpooled_height_ = -1;
    unpooled_width_ = -1;
}

template<typename Dtype>
void UnPoolingLayer<Dtype>::Reshape(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    channels_ = bottom[0]->channels();
    height_ = bottom[0]->height();
    width_ = bottom[0]->width();

    unpooled_height_ = (height_ - 1) * stride_h_ + kernel_h_ - 2 * pad_h_;
    unpooled_width_ = (width_ - 1) * stride_w_ + kernel_w_ - 2 * pad_w_;

    top[0]->Reshape(bottom[0]->num(), channels_, unpooled_height_,
            unpooled_width_);
}

// TODO(Yangqing): Is there a faster way to do unpooling in the channel-first
// case?
template<typename Dtype>
void UnPoolingLayer<Dtype>::Forward_cpu(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    const Dtype* bottom_data = bottom[0]->cpu_data();
    Dtype* top_data = top[0]->mutable_cpu_data();
    const int top_count = top[0]->count();

    // here we don't use any mask
    // const bool use_bottom_mask = false;

    // now we ony support max
    switch (this->layer_param_.unpooling_param().unpool()) {
    case UnPoolingParameter_UnPoolMethod_MAX:
        // Initialize
        caffe_set(top_count, Dtype(0), top_data);

        // The main loop
        for (int n = 0; n < bottom[0]->num(); ++n) {
            for (int c = 0; c < channels_; ++c) {
                for (int ph = 0; ph < height_; ++ph) {
                    for (int pw = 0; pw < width_; ++pw) {
                        // here be more strict
                        // because pad == 0
                        // && height_ * stride + kernel <= unpooled_height_
                        // we put the point at left up corner
                        int uph = ph * stride_h_;
                        int upw = pw * stride_w_;
                        const int index = ph * width_ + pw;
                        const int unpooled_index = uph * unpooled_width_ + upw;
                        top_data[unpooled_index] = bottom_data[index];
                    }
                }
                // compute offset
                bottom_data += bottom[0]->offset(0, 1);
                top_data += top[0]->offset(0, 1);
            }
        }
        break;
        // average
    case UnPoolingParameter_UnPoolMethod_AVE:
        // The main loop
        for (int n = 0; n < top[0]->num(); ++n) {
            for (int c = 0; c < channels_; ++c) {
                for (int ph = 0; ph < height_; ++ph) {
                    for (int pw = 0; pw < width_; ++pw) {
                        int hstart = ph * stride_h_ - pad_h_;
                        int wstart = pw * stride_w_ - pad_w_;
                        int hend = min(hstart + kernel_h_,
                                unpooled_height_ + pad_h_);
                        int wend = min(wstart + kernel_w_,
                                unpooled_width_ + pad_w_);
                        int pool_size = (hend - hstart) * (wend - wstart);
                        hstart = max(hstart, 0);
                        wstart = max(wstart, 0);
                        hend = min(hend, unpooled_height_);
                        wend = min(wend, unpooled_width_);
                        for (int h = hstart; h < hend; ++h) {
                            for (int w = wstart; w < wend; ++w) {
                                top_data[h * unpooled_width_ + w] +=
                                        bottom_data[ph * width_ + pw]
                                                / pool_size;
                            }
                        }
                    }
                }
                // offset
                bottom_data += bottom[0]->offset(0, 1);
                top_data += top[0]->offset(0, 1);
            }
        }
        break;
    default:
        LOG(FATAL)<< "Unknown unpooling method.";
    }
}

template<typename Dtype>
void UnPoolingLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
        const vector<bool>& propagate_down,
        const vector<Blob<Dtype>*>& bottom) {
    if (!propagate_down[0]) {
        return;
    }
    const Dtype* top_diff = top[0]->cpu_diff();
    Dtype* bottom_diff = bottom[0]->mutable_cpu_diff();
    // Different unpooling methods. We explicitly do the switch outside the for
    // loop to save time, although this results in more codes.
    caffe_set(bottom[0]->count(), Dtype(0), bottom_diff);

    // here we do not use mask
    // const bool use_bottom_mask = false;

    switch (this->layer_param_.unpooling_param().unpool()) {
    case UnPoolingParameter_UnPoolMethod_MAX:

        // The main loop
        for (int n = 0; n < top[0]->num(); ++n) {
            for (int c = 0; c < channels_; ++c) {
                for (int ph = 0; ph < height_; ++ph) {
                    for (int pw = 0; pw < width_; ++pw) {
                        // here be more strict
                        // because pad == 0
                        // && height_ * stride + kernel <= unpooled_height_
                        // we put the point at left up corner
                        int uph = ph * stride_h_;
                        int upw = pw * stride_w_;

                        const int index = ph * width_ + pw;
                        const int unpooled_index = uph * unpooled_width_ + upw;

                        bottom_diff[index] = top_diff[unpooled_index];
                    }
                }
                // compute offset
                bottom_diff += bottom[0]->offset(0, 1);
                top_diff += top[0]->offset(0, 1);
            }
        }
        break;
        // average
    case UnPoolingParameter_UnPoolMethod_AVE:

        // The main loop
        for (int n = 0; n < bottom[0]->num(); ++n) {
            for (int c = 0; c < channels_; ++c) {
                for (int ph = 0; ph < height_; ++ph) {
                    for (int pw = 0; pw < width_; ++pw) {
                        int hstart = ph * stride_h_ - pad_h_;
                        int wstart = pw * stride_w_ - pad_w_;
                        int hend = min(hstart + kernel_h_,
                                unpooled_height_ + pad_h_);
                        int wend = min(wstart + kernel_w_,
                                unpooled_width_ + pad_w_);
                        int pool_size = (hend - hstart) * (wend - wstart);
                        hstart = max(hstart, 0);
                        wstart = max(wstart, 0);
                        hend = min(hend, unpooled_height_);
                        wend = min(wend, unpooled_width_);
                        for (int h = hstart; h < hend; ++h) {
                            for (int w = wstart; w < wend; ++w) {
                                bottom_diff[ph * width_ + pw] += top_diff[h
                                        * unpooled_width_ + w];
                            }
                        }
                        bottom_diff[ph * width_ + pw] /= pool_size;
                    }
                }
                // compute offset
                bottom_diff += bottom[0]->offset(0, 1);
                top_diff += top[0]->offset(0, 1);
            }
        }
        break;
    default:
        LOG(FATAL)<< "Unknown unpooling method.";
    }
}

#ifdef CPU_ONLY
STUB_GPU(UnpoolingLayer);
#endif

INSTANTIATE_CLASS(UnPoolingLayer);

} // namespace caffe
