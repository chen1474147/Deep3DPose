#include <vector>

#include "caffe/layer.hpp"
#include "caffe/util/io.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/vision_layers.hpp"

#include "caffe/messenger.hpp"

namespace caffe {

class EUHandler: public Listener {
public:
    EUHandler(bool *is_train_grl) :
            is_train_grl_(*is_train_grl) {
    }
    void handle(void* message) {
        is_train_grl_ = *(static_cast<bool*>(message));
    }
private:
    bool& is_train_grl_;
};

template<typename Dtype>
void EuclideanLossLayer<Dtype>::LayerSetUp(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    // call base class
    LossLayer<Dtype>::LayerSetUp(bottom, top);

    if (this->layer_param_.loss_param().has_is_grl_loss()) {
        is_grl_loss = this->layer_param_.loss_param().is_grl_loss();
    } else {
        is_grl_loss = 0;
    }

    if (is_grl_loss == 0) {
        LOG(INFO)<< "This EuclideanLossLayer is normal layer";
    } else if (is_grl_loss == 1) {
        LOG(INFO) << "This EuclideanLossLayer is grl layer";
    } else if (is_grl_loss == 2) {
        LOG(INFO) << "This EuclideanLossLayer is NOT grl layer";
    } else {
        LOG(FATAL) << "This EuclideanLossLayer is unknown layer";
    }

    is_grl_train = false;

    Messenger::AddListener("IS_TRAIN_GRL_CHANGED",
            new EUHandler(&is_grl_train));
}

template<typename Dtype>
void EuclideanLossLayer<Dtype>::Reshape(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    LossLayer<Dtype>::Reshape(bottom, top);
    CHECK_EQ(bottom[0]->count(1), bottom[1]->count(1))<< "Inputs must have the same dimension.";
    diff_.ReshapeLike(*bottom[0]);
}

template<typename Dtype>
void EuclideanLossLayer<Dtype>::Forward_cpu(const vector<Blob<Dtype>*>& bottom,
        const vector<Blob<Dtype>*>& top) {
    int count = bottom[0]->count();
    caffe_sub(count, bottom[0]->cpu_data(), bottom[1]->cpu_data(),
            diff_.mutable_cpu_data());
    Dtype dot = caffe_cpu_dot(count, diff_.cpu_data(), diff_.cpu_data());
    Dtype loss = dot / bottom[0]->num() / Dtype(2);
    top[0]->mutable_cpu_data()[0] = loss;
}

template<typename Dtype>
void EuclideanLossLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
        const vector<bool>& propagate_down,
        const vector<Blob<Dtype>*>& bottom) {

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
        if (is_grl_loss == 2) {
            if (propagate_down[0]) {
                caffe_set(bottom[0]->count(), Dtype(0),
                        bottom[0]->mutable_cpu_diff());
            }
            if (propagate_down[1]) {
                caffe_set(bottom[1]->count(), Dtype(0),
                        bottom[1]->mutable_cpu_diff());
            }
            ispropagationdown = false;
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
        if (is_grl_loss == 1) {
            if (propagate_down[0]) {
                caffe_set(bottom[0]->count(), Dtype(0),
                        bottom[0]->mutable_cpu_diff());
            }
            if (propagate_down[1]) {
                caffe_set(bottom[1]->count(), Dtype(0),
                        bottom[1]->mutable_cpu_diff());
            }
            ispropagationdown = false;
        }
    }

    for (int i = 0; i < 2; ++i) {
        if (propagate_down[i] && ispropagationdown) {
            const Dtype sign = (i == 0) ? 1 : -1;
            const Dtype alpha = sign * top[0]->cpu_diff()[0] / bottom[i]->num();
            caffe_cpu_axpby(bottom[i]->count(), // count
                    alpha, // alpha
                    diff_.cpu_data(), // a
                    Dtype(0), // beta
                    bottom[i]->mutable_cpu_diff()); // b
        }
    }
}

#ifdef CPU_ONLY
STUB_GPU(EuclideanLossLayer);
#endif

INSTANTIATE_CLASS(EuclideanLossLayer);
REGISTER_LAYER_CLASS(EuclideanLoss);

} // namespace caffe
