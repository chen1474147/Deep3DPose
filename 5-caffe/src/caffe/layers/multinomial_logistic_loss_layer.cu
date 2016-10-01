#include <algorithm>
#include <cfloat>
#include <vector>

#include "caffe/layer.hpp"
#include "caffe/util/math_functions.hpp"
#include "caffe/vision_layers.hpp"

namespace caffe {

template<typename Dtype>
__global__ void MultinomialLogisticLossForwardGPU(const int nthreads,
        const Dtype* data, const Dtype* label, Dtype* loss, const int num,
        const int dim) {

    CUDA_KERNEL_LOOP(index, nthreads)
    {

        const int n = index / dim;
        const int s = index % dim;

        const Dtype label_value = label[n * dim + s];
        const Dtype prob = max(data[n * dim + s], Dtype(FLT_MIN));
        loss[n * dim + s] = -label_value * log(prob);
    }
}

template<typename Dtype>
void MultinomialLogisticLossLayer<Dtype>::Forward_gpu(
        const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {

    const Dtype* bottom_data = bottom[0]->gpu_data();
    const Dtype* bottom_label = bottom[1]->gpu_data();
    const int num = bottom[0]->num();
    const int dim = bottom[0]->count() / bottom[0]->num();
    const int nthreads = num * dim;

    // Since this memory is not used for anything until it is overwritten
    // on the backward pass, we use it here to avoid having to allocate new GPU
    // memory to accumulate intermediate results in the kernel.
    Dtype* loss_data = bottom[0]->mutable_gpu_diff();
    caffe_gpu_set(bottom[0]->count(), Dtype(0), loss_data);

    // NOLINT_NEXT_LINE(whitespace/operators)
    MultinomialLogisticLossForwardGPU<Dtype> <<<CAFFE_GET_BLOCKS(nthreads),
            CAFFE_CUDA_NUM_THREADS>>>(nthreads, bottom_data, bottom_label,
            loss_data, num, dim);

    Dtype loss;
    caffe_gpu_asum(nthreads, loss_data, &loss);
    loss = loss / nthreads;

    top[0]->mutable_cpu_data()[0] = loss;
}

template<typename Dtype>
__global__ void MultinomialLogisticLossBackwardGPU(const int nthreads,
        const Dtype* data, const Dtype* label, Dtype* bottom_diff,
        const int num, const int dim, const Dtype scale) {

    CUDA_KERNEL_LOOP(index, nthreads)
    {

        const int n = index / dim;
        const int s = index % dim;

        const Dtype label_value = label[n * dim + s];
        const Dtype prob = max(data[n * dim + s], Dtype(FLT_MIN));

        bottom_diff[n * dim + s] = scale * label_value / prob;
    }
}

template<typename Dtype>
void MultinomialLogisticLossLayer<Dtype>::Backward_gpu(
        const vector<Blob<Dtype>*>& top, const vector<bool>& propagate_down,
        const vector<Blob<Dtype>*>& bottom) {

    bool ispropagationdown = true;
    if (is_grl_train) {
        if (is_grl_loss == 2) {
            ispropagationdown = false;
            if (propagate_down[0]) {
                Dtype* bottom_diff = bottom[0]->mutable_gpu_diff();
                caffe_gpu_set(bottom[0]->count(), Dtype(0), bottom_diff);
            }
        }
    } else {
        if (is_grl_loss == 1) {
            ispropagationdown = false;
            if (propagate_down[0]) {
                Dtype* bottom_diff = bottom[0]->mutable_gpu_diff();
                caffe_gpu_set(bottom[0]->count(), Dtype(0), bottom_diff);
            }
        }
    }

    // Backward_cpu(top, propagate_down, bottom);
    if (propagate_down[1]) {
        LOG(FATAL)<< this->type()
        << " Layer cannot backpropagate to label inputs.";
    }

    if (propagate_down[0] && ispropagationdown) {
        const Dtype* bottom_data = bottom[0]->gpu_data();
        const Dtype* bottom_label = bottom[1]->gpu_data();

        Dtype* bottom_diff = bottom[0]->mutable_gpu_diff();
        caffe_gpu_set(bottom[0]->count(), Dtype(0), bottom_diff);

        const int num = bottom[0]->num();
        const int dim = bottom[0]->count() / bottom[0]->num();
        const int nthreads = num * dim;

        const Dtype scale = -top[0]->cpu_diff()[0] / nthreads;

        MultinomialLogisticLossBackwardGPU<Dtype> <<<CAFFE_GET_BLOCKS(nthreads),
                CAFFE_CUDA_NUM_THREADS>>>(nthreads, bottom_data, bottom_label,
                bottom_diff, num, dim, scale);
    }
}

INSTANTIATE_LAYER_GPU_FUNCS(MultinomialLogisticLossLayer);

} // namespace caffe
