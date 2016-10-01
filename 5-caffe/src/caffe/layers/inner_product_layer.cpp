#include <vector>

#include "caffe/blob.hpp"
#include "caffe/common.hpp"
#include "caffe/filler.hpp"
#include "caffe/layer.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/vision_layers.hpp"

#include "caffe/messenger.hpp"

namespace caffe {

class FC2Handler: public Listener {
public:
    FC2Handler(bool *is_grl_train) :
            is_grl_train_(*is_grl_train) {
    }
    void handle(void* message) {
        is_grl_train_ = *(static_cast<bool*>(message));
    }
private:
    bool& is_grl_train_;
};

template<typename Dtype>
void InnerProductLayer<Dtype>::LayerSetUp(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    const int num_output =
            this->layer_param_.inner_product_param().num_output();
    bias_term_ = this->layer_param_.inner_product_param().bias_term();
    N_ = num_output;
    const int axis = bottom[0]->CanonicalAxisIndex(
            this->layer_param_.inner_product_param().axis());
    // Dimensions starting from "axis" are "flattened" into a single
    // length K_ vector. For example, if bottom[0]'s shape is (N, C, H, W),
    // and axis == 1, N inner products with dimension CHW are performed.
    K_ = bottom[0]->count(axis);
    // Check if we need to set up the weights
    if (this->blobs_.size() > 0) {
        LOG(INFO)<< "Skipping parameter initialization";
    } else {
        if (bias_term_) {
            this->blobs_.resize(2);
        } else {
            this->blobs_.resize(1);
        }
        // Intialize the weight
        vector<int> weight_shape(2);
        weight_shape[0] = N_;
        weight_shape[1] = K_;
        this->blobs_[0].reset(new Blob<Dtype>(weight_shape));
        // fill the weights
        shared_ptr<Filler<Dtype> > weight_filler(GetFiller<Dtype>(
                        this->layer_param_.inner_product_param().weight_filler()));
        weight_filler->Fill(this->blobs_[0].get());
        // If necessary, intiialize and fill the bias term
        if (bias_term_) {
            vector<int> bias_shape(1, N_);
            this->blobs_[1].reset(new Blob<Dtype>(bias_shape));
            shared_ptr<Filler<Dtype> > bias_filler(GetFiller<Dtype>(
                            this->layer_param_.inner_product_param().bias_filler()));
            bias_filler->Fill(this->blobs_[1].get());
        }
    } // parameter initialization
    this->param_propagate_down_.resize(this->blobs_.size(), true);

    // parameter
    if (this->layer_param_.inner_product_param().has_is_grl_layer()) {
        is_grl_layer = this->layer_param_.inner_product_param().is_grl_layer();
    } else {
        is_grl_layer = 0;
    }

    if (is_grl_layer == 0) {
        LOG(INFO)<< "This FC Layer is normal layer";
    } else if (is_grl_layer == 1) {
        LOG(INFO) << "This FC Layer is grl layer";
    } else if (is_grl_layer == 2) {
        LOG(INFO) << "This FC Layer is NOT grl layer";
    } else {
        LOG(FATAL) << "This FC Layer is unknown layer";
    }

    is_grl_train = false;

    // listener
    Messenger::AddListener("IS_TRAIN_GRL_CHANGED",
            new FC2Handler(&is_grl_train));
}

template<typename Dtype>
void InnerProductLayer<Dtype>::Reshape(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    // Figure out the dimensions
    const int axis = bottom[0]->CanonicalAxisIndex(
            this->layer_param_.inner_product_param().axis());
    const int new_K = bottom[0]->count(axis);
    CHECK_EQ(K_, new_K)<< "Input size incompatible with inner product parameters.";
    // The first "axis" dimensions are independent inner products; the total
    // number of these is M_, the product over these dimensions.
    M_ = bottom[0]->count(0, axis);
    // The top shape will be the bottom shape with the flattened axes dropped,
    // and replaced by a single axis with dimension num_output (N_).
    vector<int> top_shape = bottom[0]->shape();
    top_shape.resize(axis + 1);
    top_shape[axis] = N_;
    top[0]->Reshape(top_shape);
    // Set up the bias multiplier
    if (bias_term_) {
        vector<int> bias_shape(1, M_);
        bias_multiplier_.Reshape(bias_shape);
        caffe_set(M_, Dtype(1), bias_multiplier_.mutable_cpu_data());
    }
}

template<typename Dtype>
void InnerProductLayer<Dtype>::Forward_cpu(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    const Dtype* bottom_data = bottom[0]->cpu_data();
    Dtype* top_data = top[0]->mutable_cpu_data();
    const Dtype* weight = this->blobs_[0]->cpu_data();
    caffe_cpu_gemm<Dtype>(CblasNoTrans, CblasTrans, M_, N_, K_, (Dtype) 1.,
            bottom_data, weight, (Dtype) 0., top_data);
    if (bias_term_) {
        caffe_cpu_gemm<Dtype>(CblasNoTrans, CblasNoTrans, M_, N_, 1, (Dtype) 1.,
                bias_multiplier_.cpu_data(), this->blobs_[1]->cpu_data(),
                (Dtype) 1., top_data);
    }
}

template<typename Dtype>
void InnerProductLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
        const vector<bool>& propagate_down,
        const vector<Blob<Dtype>*>& bottom) {

    bool ispropagationweights = true;
    bool ispropagationdown = true;
    if (is_grl_train) {
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
        if (is_grl_layer == 2) {
            ispropagationweights = false;
            ispropagationdown = false;
            caffe_set(this->blobs_[0]->count(), Dtype(0),
                    this->blobs_[0]->mutable_cpu_diff());
            caffe_set(this->blobs_[1]->count(), Dtype(0),
                    this->blobs_[1]->mutable_cpu_diff());
            caffe_set(bottom[0]->count(), Dtype(0),
                    bottom[0]->mutable_cpu_diff());
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
        if (is_grl_layer == 1) {
            ispropagationweights = false;
            ispropagationdown = true;
            caffe_set(this->blobs_[0]->count(), Dtype(0),
                    this->blobs_[0]->mutable_cpu_diff());
            caffe_set(this->blobs_[1]->count(), Dtype(0),
                    this->blobs_[1]->mutable_cpu_diff());
        }
    }

    if (this->param_propagate_down_[0] && ispropagationweights) {
        const Dtype* top_diff = top[0]->cpu_diff();
        const Dtype* bottom_data = bottom[0]->cpu_data();
        // Gradient with respect to weight
        caffe_cpu_gemm<Dtype>(CblasTrans, CblasNoTrans, N_, K_, M_, (Dtype) 1.,
                top_diff, bottom_data, (Dtype) 0.,
                this->blobs_[0]->mutable_cpu_diff());
    }
    if (bias_term_ && this->param_propagate_down_[1] && ispropagationweights) {
        const Dtype* top_diff = top[0]->cpu_diff();
        // Gradient with respect to bias
        caffe_cpu_gemv<Dtype>(CblasTrans, M_, N_, (Dtype) 1., top_diff,
                bias_multiplier_.cpu_data(), (Dtype) 0.,
                this->blobs_[1]->mutable_cpu_diff());
    }
    if (propagate_down[0] && ispropagationdown) {
        const Dtype* top_diff = top[0]->cpu_diff();
        // Gradient with respect to bottom data
        caffe_cpu_gemm<Dtype>(CblasNoTrans, CblasNoTrans, M_, K_, N_,
                (Dtype) 1., top_diff, this->blobs_[0]->cpu_data(), (Dtype) 0.,
                bottom[0]->mutable_cpu_diff());
    }
}

#ifdef CPU_ONLY
STUB_GPU(InnerProductLayer);
#endif

INSTANTIATE_CLASS(InnerProductLayer);
REGISTER_LAYER_CLASS(InnerProduct);

} // namespace caffe
