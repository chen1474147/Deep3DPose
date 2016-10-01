#include <algorithm>
#include <cfloat>
#include <cmath>
#include <vector>

#include "caffe/layer.hpp"
#include "caffe/util/io.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/vision_layers.hpp"

#include "caffe/messenger.hpp"

namespace caffe {

class MUHandler: public Listener {
public:
    MUHandler(bool *is_train_grl) :
            is_train_grl_(*is_train_grl) {
    }
    void handle(void* message) {
        is_train_grl_ = *(static_cast<bool*>(message));
    }
private:
    bool& is_train_grl_;
};

template<typename Dtype>
void MultinomialLogisticLossLayer<Dtype>::LayerSetUp(
        const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
    // call base class
    LossLayer<Dtype>::LayerSetUp(bottom, top);

    if (this->layer_param_.loss_param().has_is_grl_loss()) {
        is_grl_loss = this->layer_param_.loss_param().is_grl_loss();
    } else {
        is_grl_loss = 0;
    }

    if (is_grl_loss == 0) {
        LOG(INFO)<< "This MultinomialLogisticLossLayer is normal layer";
    } else if (is_grl_loss == 1) {
        LOG(INFO) << "This MultinomialLogisticLossLayer is grl layer";
    } else if (is_grl_loss == 2) {
        LOG(INFO) << "This MultinomialLogisticLossLayer is NOT grl layer";
    } else {
        LOG(FATAL) << "This MultinomialLogisticLossLayer is unknown layer";
    }

    is_grl_train = false;

    Messenger::AddListener("IS_TRAIN_GRL_CHANGED",
            new MUHandler(&is_grl_train));
}

template<typename Dtype>
void MultinomialLogisticLossLayer<Dtype>::Reshape(
        const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
    LossLayer<Dtype>::Reshape(bottom, top);

    // the source shape should the same as label shape
    CHECK_EQ(bottom[1]->channels(), bottom[0]->channels());

    CHECK_EQ(bottom[1]->height(), 1);
    CHECK_EQ(bottom[1]->width(), 1);
}

template<typename Dtype>
void MultinomialLogisticLossLayer<Dtype>::Forward_cpu(
        const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
    const Dtype* bottom_data = bottom[0]->cpu_data();
    const Dtype* bottom_label = bottom[1]->cpu_data();
    int num = bottom[0]->num();
    int dim = bottom[0]->count() / bottom[0]->num();
    Dtype loss = 0;
    for (int i = 0; i < num; ++i) {
        /*
         int label = static_cast<int>(bottom_label[i]);
         Dtype prob = std::max(bottom_data[i * dim + label],
         Dtype(kLOG_THRESHOLD));
         loss -= log(prob);
         */
        for (int j = 0; j < dim; j++) {
            Dtype label = bottom_label[i * dim + j];
            Dtype prob = std::max(bottom_data[i * dim + j],
                    Dtype(kLOG_THRESHOLD));
            loss -= label * log(prob);
        }
    }
    top[0]->mutable_cpu_data()[0] = loss / num / dim;
}

template<typename Dtype>
void MultinomialLogisticLossLayer<Dtype>::Backward_cpu(
        const vector<Blob<Dtype>*>& top, const vector<bool>& propagate_down,
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
            ispropagationdown = false;
        }
    }

    if (propagate_down[1]) {
        LOG(FATAL)<< this->type()
        << " Layer cannot backpropagate to label inputs.";
    }
    if (propagate_down[0] && ispropagationdown) {
        const Dtype* bottom_data = bottom[0]->cpu_data();
        const Dtype* bottom_label = bottom[1]->cpu_data();
        Dtype* bottom_diff = bottom[0]->mutable_cpu_diff();
        int num = bottom[0]->num();
        int dim = bottom[0]->count() / bottom[0]->num();
        caffe_set(bottom[0]->count(), Dtype(0), bottom_diff);
        const Dtype scale = -top[0]->cpu_diff()[0] / num / dim;
        for (int i = 0; i < num; ++i) {
            /*
             int label = static_cast<int>(bottom_label[i]);
             Dtype prob = std::max(bottom_data[i * dim + label],
             Dtype(kLOG_THRESHOLD));
             bottom_diff[i * dim + label] = scale / prob;
             */
            for (int j = 0; j < dim; j++) {
                Dtype label = bottom_label[i * dim + j];
                Dtype prob = std::max(bottom_data[i * dim + j],
                        Dtype(kLOG_THRESHOLD));
                bottom_diff[i * dim + j] = scale * label / prob;
            }
        }
    }
}

INSTANTIATE_CLASS(MultinomialLogisticLossLayer);
REGISTER_LAYER_CLASS(MultinomialLogisticLoss);

} // namespace caffe
