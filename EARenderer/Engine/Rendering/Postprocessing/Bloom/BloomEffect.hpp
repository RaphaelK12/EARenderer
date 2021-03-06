//
//  BloomFilter.hpp
//  EARenderer
//
//  Created by Pavel Muratov on 6/26/18.
//  Copyright © 2018 MPO. All rights reserved.
//

#ifndef BloomFilter_hpp
#define BloomFilter_hpp

#include "PostprocessEffect.hpp"
#include "GLTexture2D.hpp"
#include "GaussianBlurEffect.hpp"
#include "GLFramebuffer.hpp"
#include "GLSLBloom.hpp"
#include "BloomSettings.hpp"

#include <memory>

namespace EARenderer {

    class BloomEffect : public PostprocessEffect {
    private:
        GaussianBlurEffect mSmallBlurEffect;
        GaussianBlurEffect mMediumBlurEffect;
        GaussianBlurEffect mLargeBlurEffect;

        GLSLBloom mBloomShader;

    public:
        BloomEffect(GLFramebuffer *sharedFramebuffer, PostprocessTexturePool *sharedTexturePool);

        void bloom(
                const PostprocessTexturePool::PostprocessTexture &baseImage,
                PostprocessTexturePool::PostprocessTexture &thresholdFilteredImage,
                PostprocessTexturePool::PostprocessTexture &outputImage,
                const BloomSettings &settings
        );
    };

}

#endif /* BloomFilter_hpp */
