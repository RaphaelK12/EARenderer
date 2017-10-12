//
//  GLBindable.hpp
//  EARenderer
//
//  Created by Pavlo Muratov on 18.03.17.
//  Copyright © 2017 MPO. All rights reserved.
//

#ifndef GLBindable_hpp
#define GLBindable_hpp

#include <OpenGL/gl3.h>

namespace EARenderer {
    
    class GLBindable {
    public:
        virtual void bind() const = 0;
    };
    
}

#endif /* GLBindable_hpp */