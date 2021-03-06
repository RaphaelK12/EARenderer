//
//  GLSLSurfelLighting.hpp
//  EARenderer
//
//  Created by Pavlo Muratov on 21.03.2018.
//  Copyright © 2018 MPO. All rights reserved.
//

#ifndef GLSLSurfelLighting_hpp
#define GLSLSurfelLighting_hpp

#include "GLProgram.hpp"
#include "GLTexture2DArray.hpp"
#include "DirectionalLight.hpp"
#include "PointLight.hpp"
#include "GLTexture2D.hpp"
#include "GLHDRTexture3D.hpp"
#include "GLLDRTexture3D.hpp"
#include "GLBufferTexture.hpp"
#include "RenderingSettings.hpp"

namespace EARenderer {

    class GLSLSurfelLighting : public GLProgram {
    public:
        GLSLSurfelLighting();

        void setLightType(LightType type);

        void setLight(const DirectionalLight &light);

        void setSurfelsGBuffer(const GLFloatTexture2DArray<GLTexture::Float::RGB32F> &gBuffer);

        void setGridProbesSHTextures(const std::array<GLLDRTexture3D, 4> &textures);

        void setWorldBoundingBox(const AxisAlignedBox3D &box);

        void setProbePositions(const GLFloatBufferTexture<GLTexture::Float::RGB32F, glm::vec3> &positions);

        void setShadowCascades(const FrustumCascades &cascades);

        void setDirectionalShadowMapArray(const GLDepthTexture2DArray &array);

        void setOmnidirectionalShadowMap(const GLDepthTextureCubemap &shadowMap);

        void setSettings(const RenderingSettings &settings);
    };

}

#endif /* GLSLSurfelLighting_hpp */
