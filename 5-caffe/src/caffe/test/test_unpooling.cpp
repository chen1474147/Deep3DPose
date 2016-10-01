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
class UnPoolingLayerTest: public MultiDeviceTest<TypeParam> {
    typedef typename TypeParam::Dtype Dtype;

protected:
    UnPoolingLayerTest() :
            blob_bottom_(new Blob<Dtype>()), blob_top_(new Blob<Dtype>()) {
    }
    virtual void SetUp() {
        Caffe::set_random_seed(1701);
        blob_bottom_->Reshape(2, 3, 7, 7);
        // fill the values
        FillerParameter filler_param;
        GaussianFiller<Dtype> filler(filler_param);
        filler.Fill(this->blob_bottom_);
        blob_bottom_vec_.push_back(blob_bottom_);
        blob_top_vec_.push_back(blob_top_);
    }
    virtual ~UnPoolingLayerTest() {
        delete blob_bottom_;
        delete blob_top_;
    }
    Blob<Dtype>* const blob_bottom_;
    Blob<Dtype>* const blob_top_;
    vector<Blob<Dtype>*> blob_bottom_vec_;
    vector<Blob<Dtype>*> blob_top_vec_;

    // Test for 2x 2 square pooling layer
    void TestForwardSquare() {
        LayerParameter layer_param;
        UnPoolingParameter* pooling_param =
                layer_param.mutable_unpooling_param();
        pooling_param->set_kernel_size(3);
        pooling_param->set_stride(2);
        pooling_param->set_unpool(UnPoolingParameter_UnPoolMethod_MAX);
        const int num = 2;
        const int channels = 2;
        blob_bottom_->Reshape(num, channels, 3, 3);
        // Input: 2x 2 channels of:
        //     [1 2 5]
        //     [9 4 1]
        //     [1 2 5]
        for (int i = 0; i < 9 * num * channels; i += 9) {
            blob_bottom_->mutable_cpu_data()[i + 0] = 1;
            blob_bottom_->mutable_cpu_data()[i + 1] = 2;
            blob_bottom_->mutable_cpu_data()[i + 2] = 5;
            blob_bottom_->mutable_cpu_data()[i + 3] = 9;
            blob_bottom_->mutable_cpu_data()[i + 4] = 4;
            blob_bottom_->mutable_cpu_data()[i + 5] = 1;
            blob_bottom_->mutable_cpu_data()[i + 6] = 1;
            blob_bottom_->mutable_cpu_data()[i + 7] = 2;
            blob_bottom_->mutable_cpu_data()[i + 8] = 5;
        }
        UnPoolingLayer<Dtype> layer(layer_param);
        layer.SetUp(blob_bottom_vec_, blob_top_vec_);
        EXPECT_EQ(blob_top_->num(), num);
        EXPECT_EQ(blob_top_->channels(), channels);
        EXPECT_EQ(blob_top_->height(), 7);
        EXPECT_EQ(blob_top_->width(), 7);

        layer.Forward(blob_bottom_vec_, blob_top_vec_);
        // Expected output: 7 x 7 channels of:
        //     [1 0 2 0 5 0 0]
        //     [0 0 0 0 0 0 0]
        //     [9 0 4 0 1 0 0]
        //     [0 0 0 0 0 0 0]
        //     [1 0 2 0 5 0 0]
        //     [0 0 0 0 0 0 0]
        //     [0 0 0 0 0 0 0]
        for (int i = 0; i < 49 * num * channels; i += 49) {
            EXPECT_EQ(blob_top_->cpu_data()[i + 0], 1);
            EXPECT_EQ(blob_top_->cpu_data()[i + 1], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 2], 2);
            EXPECT_EQ(blob_top_->cpu_data()[i + 3], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 4], 5);
            EXPECT_EQ(blob_top_->cpu_data()[i + 5], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 6], 0);

            EXPECT_EQ(blob_top_->cpu_data()[i + 7], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 8], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 9], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 10], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 11], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 12], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 13], 0);

            EXPECT_EQ(blob_top_->cpu_data()[i + 14], 9);
            EXPECT_EQ(blob_top_->cpu_data()[i + 15], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 16], 4);
            EXPECT_EQ(blob_top_->cpu_data()[i + 17], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 18], 1);
            EXPECT_EQ(blob_top_->cpu_data()[i + 19], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 20], 0);

            EXPECT_EQ(blob_top_->cpu_data()[i + 21], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 22], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 23], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 24], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 25], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 26], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 27], 0);

            EXPECT_EQ(blob_top_->cpu_data()[i + 28], 1);
            EXPECT_EQ(blob_top_->cpu_data()[i + 29], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 30], 2);
            EXPECT_EQ(blob_top_->cpu_data()[i + 31], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 32], 5);
            EXPECT_EQ(blob_top_->cpu_data()[i + 33], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 34], 0);

            EXPECT_EQ(blob_top_->cpu_data()[i + 35], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 36], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 37], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 38], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 39], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 40], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 41], 0);

            EXPECT_EQ(blob_top_->cpu_data()[i + 42], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 43], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 44], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 45], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 46], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 47], 0);
            EXPECT_EQ(blob_top_->cpu_data()[i + 48], 0);
        }
    }

};

TYPED_TEST_CASE(UnPoolingLayerTest, TestDtypesAndDevices);

TYPED_TEST(UnPoolingLayerTest, TestSetup){
typedef typename TypeParam::Dtype Dtype;
LayerParameter layer_param;
UnPoolingParameter* pooling_param = layer_param.mutable_unpooling_param();
pooling_param->set_kernel_size(3);
pooling_param->set_stride(2);
UnPoolingLayer<Dtype> layer(layer_param);
layer.SetUp(this->blob_bottom_vec_, this->blob_top_vec_);
EXPECT_EQ(this->blob_top_->num(), this->blob_bottom_->num());
EXPECT_EQ(this->blob_top_->channels(), this->blob_bottom_->channels());
EXPECT_EQ(this->blob_top_->height(), 15);
EXPECT_EQ(this->blob_top_->width(), 15);
}

TYPED_TEST(UnPoolingLayerTest, TestForwardMax){
this->TestForwardSquare();
}

}
 // namespace caffe
