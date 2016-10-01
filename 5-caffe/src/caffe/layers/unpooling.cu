#include <algorithm>
#include <cfloat>
#include <vector>

#include "caffe/layer.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/vision_layers.hpp"

namespace caffe {

template<typename Dtype>
__global__ void MaxUnPoolForward(const int nthreads, const Dtype* bottom_data,
        const int num, const int channels, const int height, const int width,
        const int unpooled_height, const int unpooled_width, const int kernel_h,
        const int kernel_w, const int stride_h, const int stride_w,
        const int pad_h, const int pad_w, Dtype* top_data) {
    CUDA_KERNEL_LOOP(index, nthreads)
    {
        int pw = index % width;
        int ph = (index / width) % height;
        int c = (index / width / height) % channels;
        int n = index / width / height / channels;

        int uph = ph * stride_h;
        int upw = pw * stride_w;
        int unpooled_index = uph * unpooled_width + upw;

        top_data += (n * channels + c) * unpooled_height * unpooled_width;
        top_data[unpooled_index] = bottom_data[index];
    }
}

template<typename Dtype>
__global__ void AveUnPoolForward(const int nthreads, const Dtype* bottom_data,
        const int num, const int channels, const int unpooled_height,
        const int unpooled_width, const int height, const int width,
        const int kernel_h, const int kernel_w, const int stride_h,
        const int stride_w, const int pad_h, const int pad_w, Dtype* top_data) {
    CUDA_KERNEL_LOOP(index, nthreads)
    {
        // find out the local index
        // find out the local offset
        int w = index % unpooled_width + pad_w;
        int h = (index / unpooled_width) % unpooled_height + pad_h;
        int c = (index / unpooled_width / unpooled_height) % channels;
        int n = index / unpooled_width / unpooled_height / channels;

        int phstart = (h < kernel_h) ? 0 : (h - kernel_h) / stride_h + 1;
        int phend = min(h / stride_h + 1, height);
        int pwstart = (w < kernel_w) ? 0 : (w - kernel_w) / stride_w + 1;
        int pwend = min(w / stride_w + 1, width);
        Dtype distval = 0;
        bottom_data += (n * channels + c) * height * width;
        for (int ph = phstart; ph < phend; ++ph) {
            for (int pw = pwstart; pw < pwend; ++pw) {
                // figure out the pooling size
                int hstart = ph * stride_h - pad_h;
                int wstart = pw * stride_w - pad_w;
                int hend = min(hstart + kernel_h, unpooled_height + pad_h);
                int wend = min(wstart + kernel_w, unpooled_width + pad_w);
                int pool_size = (hend - hstart) * (wend - wstart);
                distval += bottom_data[ph * width + pw] / pool_size;
            }
        }
        top_data[index] = distval;
    }
}

template<typename Dtype>
void UnPoolingLayer<Dtype>::Forward_gpu(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    const Dtype* bottom_data = bottom[0]->gpu_data();
    int count = bottom[0]->count();
    Dtype* top_data = top[0]->mutable_gpu_data();
    caffe_gpu_set(top[0]->count(), Dtype(0.), top_data);

    // here we don't use mask
    // const bool use_bottom_mask = false;

    switch (this->layer_param_.unpooling_param().unpool()) {
    case UnPoolingParameter_UnPoolMethod_MAX:

        // NOLINT_NEXT_LINE(whitespace/operators)
        MaxUnPoolForward<Dtype> <<<CAFFE_GET_BLOCKS(count),
                CAFFE_CUDA_NUM_THREADS>>>(count, bottom_data, bottom[0]->num(),
                channels_, height_, width_, unpooled_height_, unpooled_width_,
                kernel_h_, kernel_w_, stride_h_, stride_w_, pad_h_, pad_w_,
                top_data);
        break;

    case UnPoolingParameter_UnPoolMethod_AVE:
        // NOLINT_NEXT_LINE(whitespace/operators)
        AveUnPoolForward<Dtype> <<<CAFFE_GET_BLOCKS(count),
                CAFFE_CUDA_NUM_THREADS>>>(top[0]->count(), bottom_data,
                bottom[0]->num(), channels_, unpooled_height_, unpooled_width_,
                height_, width_, kernel_h_, kernel_w_, stride_h_, stride_w_,
                pad_h_, pad_w_, top_data);
        break;
    default:
        LOG(FATAL)<< "Unknown unpooling method.";
    }
    CUDA_POST_KERNEL_CHECK
    ;
}

template<typename Dtype>
__global__ void MaxUnPoolBackward(const int nthreads, const Dtype* top_diff,
        const int num, const int channels, const int height, const int width,
        const int unpooled_height, const int unpooled_width, const int kernel_h,
        const int kernel_w, const int stride_h, const int stride_w,
        const int pad_h, const int pad_w, Dtype* bottom_diff) {
    CUDA_KERNEL_LOOP(index, nthreads)
    {
        // find out the local index
        // find out the local offset
        int pw = index % width;
        int ph = (index / width) % height;
        int c = (index / width / height) % channels;
        int n = index / width / height / channels;

        // here be more strict
        // because pad == 0
        // && height_ * stride + kernel <= unpooled_height_
        // we put the point at left up corner
        int uph = ph * stride_h;
        int upw = pw * stride_w;
        int unpooled_index = uph * unpooled_width + upw;

        top_diff += (n * channels + c) * unpooled_height * unpooled_width;
        bottom_diff[index] = top_diff[unpooled_index];
    }
}

template<typename Dtype>
__global__ void AveUnPoolBackward(const int nthreads, const Dtype* top_diff,
        const int num, const int channels, const int unpooled_height,
        const int unpooled_width, const int height, const int width,
        const int kernel_h, const int kernel_w, const int stride_h,
        const int stride_w, const int pad_h, const int pad_w,
        Dtype* bottom_diff) {
    CUDA_KERNEL_LOOP(index, nthreads)
    {
        int pw = index % width;
        int ph = (index / width) % height;
        int c = (index / width / height) % channels;
        int n = index / width / height / channels;
        int hstart = ph * stride_h - pad_h;
        int wstart = pw * stride_w - pad_w;
        int hend = min(hstart + kernel_h, unpooled_height + pad_h);
        int wend = min(wstart + kernel_w, unpooled_width + pad_w);
        int pool_size = (hend - hstart) * (wend - wstart);
        hstart = max(hstart, 0);
        wstart = max(wstart, 0);
        hend = min(hend, unpooled_height);
        wend = min(wend, unpooled_width);
        Dtype gradient = 0;
        top_diff += (n * channels + c) * unpooled_height * unpooled_width;
        for (int h = hstart; h < hend; ++h) {
            for (int w = wstart; w < wend; ++w) {
                gradient += top_diff[h * unpooled_width + w];
            }
        }
        bottom_diff[index] = gradient / pool_size;
    }
}

template<typename Dtype>
void UnPoolingLayer<Dtype>::Backward_gpu(const vector<Blob<Dtype>*>& top,
        const vector<bool>& propagate_down,
        const vector<Blob<Dtype>*>& bottom) {
    if (!propagate_down[0]) {
        return;
    }
    const Dtype* top_diff = top[0]->gpu_diff();
    Dtype* bottom_diff = bottom[0]->mutable_gpu_diff();
    const int count = bottom[0]->count();
    caffe_gpu_set(count, Dtype(0.), bottom_diff);

    // disable mask
    // const bool use_bottom_mask = false;

    switch (this->layer_param_.unpooling_param().unpool()) {
    case UnPoolingParameter_UnPoolMethod_MAX:

        // NOLINT_NEXT_LINE(whitespace/operators)
        MaxUnPoolBackward<Dtype> <<<CAFFE_GET_BLOCKS(count),
                CAFFE_CUDA_NUM_THREADS>>>(count, top_diff, top[0]->num(),
                channels_, height_, width_, unpooled_height_, unpooled_width_,
                kernel_h_, kernel_w_, stride_h_, stride_w_, pad_h_, pad_w_,
                bottom_diff);
        break;

    case UnPoolingParameter_UnPoolMethod_AVE:
        // NOLINT_NEXT_LINE(whitespace/operators)
        AveUnPoolBackward<Dtype> <<<CAFFE_GET_BLOCKS(count),
                CAFFE_CUDA_NUM_THREADS>>>(bottom[0]->count(), top_diff,
                top[0]->num(), channels_, unpooled_height_, unpooled_width_,
                height_, width_, kernel_h_, kernel_w_, stride_h_, stride_w_,
                pad_h_, pad_w_, bottom_diff);
        break;
    default:
        LOG(FATAL)<< "Unknown unpooling method.";
    }
    CUDA_POST_KERNEL_CHECK
    ;
}

INSTANTIATE_LAYER_GPU_FUNCS(UnPoolingLayer);

} // namespace caffe
