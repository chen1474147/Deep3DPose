#include <vector>

#include "caffe/filler.hpp"
#include "caffe/layer.hpp"
#include "caffe/util/im2col.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/vision_layers.hpp"

namespace caffe {

template<typename Dtype>
void ConvolutionLayer<Dtype>::compute_output_shape() {
    this->height_out_ = (this->height_ + 2 * this->pad_h_ - this->kernel_h_)
            / this->stride_h_ + 1;
    this->width_out_ = (this->width_ + 2 * this->pad_w_ - this->kernel_w_)
            / this->stride_w_ + 1;
}

template<typename Dtype>
void ConvolutionLayer<Dtype>::Forward_cpu(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    const Dtype* weight = this->blobs_[0]->cpu_data();
    for (int i = 0; i < bottom.size(); ++i) {
        const Dtype* bottom_data = bottom[i]->cpu_data();
        Dtype* top_data = top[i]->mutable_cpu_data();
        for (int n = 0; n < this->num_; ++n) {
            this->forward_cpu_gemm(bottom_data + bottom[i]->offset(n), weight,
                    top_data + top[i]->offset(n));
            if (this->bias_term_) {
                const Dtype* bias = this->blobs_[1]->cpu_data();
                this->forward_cpu_bias(top_data + top[i]->offset(n), bias);
            }
        }
    }
}

template<typename Dtype>
void ConvolutionLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
        const vector<bool>& propagate_down,
        const vector<Blob<Dtype>*>& bottom) {

    bool ispropagationweights = true;
    bool ispropagationdown = true;
    if (this->is_grl_train) {
        // when we train grl
        // and this layer belongs to grl layer
        // doing nothing

        // when we train grl
        // and this layer belongs to normal layer
        // doing nothing

        // when we train grl
        // and this layer is not grl layer
        // we will frozen its weights
        // also, we will frozen its propagation
        if (this->is_grl_layer == 2) {
            ispropagationweights = false;
            ispropagationdown = false;
            caffe_set(this->blobs_[0]->count(), Dtype(0),
                    this->blobs_[0]->mutable_cpu_diff());
            caffe_set(this->blobs_[1]->count(), Dtype(0),
                    this->blobs_[1]->mutable_cpu_diff());

            for (int i = 0; i < top.size(); ++i) {
                Dtype* bottom_diff = bottom[i]->mutable_cpu_diff();
                caffe_set(bottom[i]->count(), Dtype(0), bottom_diff);
            }
        }
    } else {
        // when we train regression task
        // and thsi layer is normal layer
        // doing nothing

        // when we train regression task
        // and thsi layer is not grl layer
        // doing nothing

        // when we train regression task
        // and this layer is grl layer
        // we will frozen its weights
        // but will let it propagate down to bottom layers
        if (this->is_grl_layer == 1) {
            ispropagationweights = false;
            ispropagationdown = true;
            caffe_set(this->blobs_[0]->count(), Dtype(0),
                    this->blobs_[0]->mutable_cpu_diff());
            caffe_set(this->blobs_[1]->count(), Dtype(0),
                    this->blobs_[1]->mutable_cpu_diff());
        }
    }

    const Dtype* weight = this->blobs_[0]->cpu_data();
    Dtype* weight_diff = this->blobs_[0]->mutable_cpu_diff();
    if (this->param_propagate_down_[0] && ispropagationweights) {
        caffe_set(this->blobs_[0]->count(), Dtype(0), weight_diff);
    }
    if (this->bias_term_ && this->param_propagate_down_[1]
            && ispropagationweights) {
        caffe_set(this->blobs_[1]->count(), Dtype(0),
                this->blobs_[1]->mutable_cpu_diff());
    }
    for (int i = 0; i < top.size(); ++i) {
        const Dtype* top_diff = top[i]->cpu_diff();
        const Dtype* bottom_data = bottom[i]->cpu_data();
        Dtype* bottom_diff = bottom[i]->mutable_cpu_diff();
        // Bias gradient, if necessary.
        if (this->bias_term_ && this->param_propagate_down_[1]
                && ispropagationweights) {
            Dtype* bias_diff = this->blobs_[1]->mutable_cpu_diff();
            for (int n = 0; n < this->num_; ++n) {
                this->backward_cpu_bias(bias_diff,
                        top_diff + top[i]->offset(n));
            }
        }
        if (this->param_propagate_down_[0] || propagate_down[i]) {
            for (int n = 0; n < this->num_; ++n) {
                // gradient w.r.t. weight. Note that we will accumulate diffs.
                if (this->param_propagate_down_[0] && ispropagationweights) {
                    this->weight_cpu_gemm(bottom_data + bottom[i]->offset(n),
                            top_diff + top[i]->offset(n), weight_diff);
                }
                // gradient w.r.t. bottom data, if necessary.
                if (propagate_down[i] && ispropagationdown) {
                    this->backward_cpu_gemm(top_diff + top[i]->offset(n),
                            weight, bottom_diff + bottom[i]->offset(n));
                }
            }
        }
    }
}

#ifdef CPU_ONLY
STUB_GPU(ConvolutionLayer);
#endif

INSTANTIATE_CLASS(ConvolutionLayer);

} // namespace caffe
