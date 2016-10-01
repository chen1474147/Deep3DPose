#include <cmath>
#include <cstdlib>
#include <cstring>
#include <vector>

#include "gtest/gtest.h"

#include "caffe/blob.hpp"
#include "caffe/common.hpp"
#include "caffe/filler.hpp"
#include "caffe/vision_layers.hpp"

#include "caffe/test/test_caffe_main.hpp"
#include "caffe/test/test_gradient_check_util.hpp"

namespace caffe {

template<typename TypeParam>
class MyLossLayerTest: public MultiDeviceTest<TypeParam> {
    typedef typename TypeParam::Dtype Dtype;

protected:
    MyLossLayerTest() :
            blob_bottom_data_(new Blob<Dtype>(200, 50, 1, 1)), blob_bottom_label_(
                    new Blob<Dtype>(200, 50, 1, 1)), blob_top_loss_(
                    new Blob<Dtype>()) {
        Caffe::set_random_seed(1701);
        // fill the values
        FillerParameter filler_param;
        PositiveUnitballFiller<Dtype> filler(filler_param);
        filler.Fill(this->blob_bottom_data_);
        blob_bottom_vec_.push_back(blob_bottom_data_);
        for (int i = 0; i < blob_bottom_label_->count(); ++i) {
            Dtype prob = caffe_rng_rand() % 100;
            prob = prob / Dtype(100);
            blob_bottom_label_->mutable_cpu_data()[i] = prob; // caffe_rng_rand() % 5;
        }
        blob_bottom_vec_.push_back(blob_bottom_label_);
        blob_top_vec_.push_back(blob_top_loss_);
    }
    virtual ~MyLossLayerTest() {
        delete blob_bottom_data_;
        delete blob_bottom_label_;
        delete blob_top_loss_;
    }
    Blob<Dtype>* const blob_bottom_data_;
    Blob<Dtype>* const blob_bottom_label_;
    Blob<Dtype>* const blob_top_loss_;
    vector<Blob<Dtype>*> blob_bottom_vec_;
    vector<Blob<Dtype>*> blob_top_vec_;
};

TYPED_TEST_CASE(MyLossLayerTest, TestDtypesAndDevices);

TYPED_TEST(MyLossLayerTest, TestGradient){
typedef typename TypeParam::Dtype Dtype;

LayerParameter layer_param;
// Caffe::set_mode(Caffe::CPU);
MultinomialLogisticLossLayer<Dtype> layer(layer_param);
layer.SetUp(this->blob_bottom_vec_, this->blob_top_vec_);
GradientChecker<Dtype> checker(1e-2, 2*1e-2, 1701, 0, 0.05);
checker.CheckGradientExhaustive(&layer, this->blob_bottom_vec_,
        this->blob_top_vec_, 0);
}

}
 // namespace caffe
