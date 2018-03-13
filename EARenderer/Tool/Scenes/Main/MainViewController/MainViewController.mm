//
//  MainViewController.m
//  EARenderer
//
//  Created by Pavlo Muratov on 23.03.17.
//  Copyright © 2017 MPO. All rights reserved.
//

#import "MainViewController.h"
#import "SceneGLView.h"
#import "SceneEditorTabView.h"
#import "SceneObjectsTabView.h"
#import "FPSView.h"

#import "DemoScene1.h"

#import "DefaultRenderComponentsProvider.h"

#import "Color.hpp"
#import "Scene.hpp"
#import "SceneRenderer.hpp"
#import "AxesRenderer.hpp"
#import "SceneInteractor.hpp"
#import "Cameraman.hpp"
#import "FileManager.hpp"
#import "FrameMeter.hpp"
#import "Throttle.hpp"
#import "SurfelRenderer.hpp"
#import "SurfelGenerator.hpp"
#import "TriangleRenderer.hpp"
#import "BoxRenderer.hpp"
#import "Measurement.hpp"

#import "GLLayeredTexture.hpp"

static float const FrequentEventsThrottleCooldownMS = 100;

@interface MainViewController () <SceneGLViewDelegate, MeshListTabViewItemDelegate>

@property (weak, nonatomic) IBOutlet SceneGLView *openGLView;
@property (weak, nonatomic) IBOutlet FPSView *fpsView;
@property (weak, nonatomic) IBOutlet SceneObjectsTabView *sceneObjectsTabView;
@property (weak, nonatomic) IBOutlet SceneEditorTabView *sceneEditorTabView;

// C++ raw pointers
@property (assign, nonatomic) EARenderer::Scene *scene;
@property (assign, nonatomic) EARenderer::SceneRenderer *sceneRenderer;
@property (assign, nonatomic) EARenderer::AxesRenderer *axesRenderer;
@property (assign, nonatomic) EARenderer::DefaultRenderComponentsProviding *defaultRenderComponentsProvider;
@property (assign, nonatomic) EARenderer::SceneInteractor *sceneInteractor;
@property (assign, nonatomic) EARenderer::Cameraman *cameraman;
@property (assign, nonatomic) EARenderer::FrameMeter *frameMeter;
@property (assign, nonatomic) EARenderer::Throttle *frequentEventsThrottle;
@property (assign, nonatomic) EARenderer::SurfelRenderer *surfelRenderer;
@property (assign, nonatomic) EARenderer::SurfelGenerator *surfelGenerator;
@property (assign, nonatomic) EARenderer::TriangleRenderer *triangleRenderer;
@property (assign, nonatomic) EARenderer::BoxRenderer *boxRenderer;

// DEBUG
@property (strong, nonatomic) DemoScene1 *demoScene;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.openGLView becomeFirstResponder];
    self.openGLView.delegate = self;    
}

#pragma mark - SceneGLViewDelegate

- (void)glViewIsReadyForInitialization:(SceneGLView *)view
{
    EARenderer::FileManager::shared().setResourceRootPath([self resourceDirectory]);
    
    EARenderer::ResourcePool *resourcePool = &EARenderer::ResourcePool::shared();
    
    self.scene = new EARenderer::Scene();
    self.frameMeter = new EARenderer::FrameMeter();
    self.frequentEventsThrottle = new EARenderer::Throttle(FrequentEventsThrottleCooldownMS);
    
    // Temporary
    
    EARenderer::Camera *camera = new EARenderer::Camera(75.f, 0.05f, 50.f);
    camera->moveTo(glm::vec3(0, 1, 0));
    camera->lookAt(glm::vec3(-1, -1, 0));
    
    self.cameraman = new EARenderer::Cameraman(camera, &EARenderer::Input::shared(), &EARenderer::GLViewport::main());
    
    auto HDRColor = EARenderer::Color(10.0, 10.0, 10.0);
    EARenderer::DirectionalLight directionalLight(HDRColor, glm::vec3(0.0, -1.0, -0.1));
    EARenderer::PointLight pointLight(glm::vec3(5, 5, -5), HDRColor);
    
    self.scene->setCamera(camera);
    self.scene->directionalLights().insert(directionalLight);
    self.scene->pointLights().insert(pointLight);
    
    [self.sceneObjectsTabView buildTabsWithScene:self.scene];
    self.sceneEditorTabView.scene = self.scene;
    
    DemoScene1 *demoScene1 = [[DemoScene1 alloc] init];
    [demoScene1 loadResourcesToPool:&EARenderer::ResourcePool::shared() andComposeScene:self.scene];
    self.demoScene = demoScene1;

    self.scene->calculateBoundingBox();

    EARenderer::Measurement::executionTime("Octree generation took", [&]() {
        self.scene->buildStaticGeometryOctree();
    });
    
    self.sceneRenderer = new EARenderer::SceneRenderer(self.scene);
    self.axesRenderer = new EARenderer::AxesRenderer(self.scene);
    self.defaultRenderComponentsProvider = new DefaultRenderComponentsProvider(&EARenderer::GLViewport::main());
    self.sceneRenderer->setDefaultRenderComponentsProvider(self.defaultRenderComponentsProvider);
    
    self.sceneInteractor = new EARenderer::SceneInteractor(&EARenderer::Input::shared(),
                                                           self.scene,
                                                           self.axesRenderer,
                                                           self.sceneRenderer,
                                                           &EARenderer::GLViewport::main());
    
    self.surfelGenerator = new EARenderer::SurfelGenerator(resourcePool, self.scene);
    self.surfelGenerator->generateStaticGeometrySurfels();

    self.surfelRenderer = new EARenderer::SurfelRenderer(self.scene, resourcePool);
    self.triangleRenderer = new EARenderer::TriangleRenderer(self.scene, resourcePool);

    self.boxRenderer = new EARenderer::BoxRenderer(self.scene);

    [self subscribeForEvents];
}

- (void)glViewIsReadyToRenderFrame:(SceneGLView *)view
{
    self.cameraman->updateCamera();
    self.sceneRenderer->render();
//    self.axesRenderer->render();
    self.surfelRenderer->render(EARenderer::SurfelRenderer::Mode::Clusters);
//    self.triangleRenderer->render();
//    self.boxRenderer->render();

    self.fpsView.frameCharacteristics = self.frameMeter->tick();
}

#pragma mark - MeshListTabViewItemDelegate

- (void)meshListTabViewItem:(MeshListTabViewItem *)item didSelectMeshWithID:(EARenderer::ID)id
{
#warning TODO: Fix later
//    EARenderer::Mesh& mesh = self.scene->meshes()[id];
//    mesh.setIsSelected(true);
//    [self.sceneEditorTabView showMeshWithID:id];
}

- (void)meshListTabViewItem:(MeshListTabViewItem *)item didDeselectMeshWithID:(EARenderer::ID)id
{
    #warning TODO: Fix later
//    EARenderer::Mesh& mesh = self.scene->meshes()[id];
//    mesh.setIsSelected(false);
}

- (void)meshListTabViewItem:(MeshListTabViewItem *)item didSelectSubMeshWithID:(EARenderer::ID)id
{
    
}

- (void)meshListTabViewItemDidDeselectAll:(MeshListTabViewItem *)item
{
    #warning TODO: Fix later
//    for (EARenderer::ID meshID : self.scene->meshes()) {
//        EARenderer::Mesh& mesh = self.scene->meshes()[meshID];
//        mesh.setIsSelected(false);
//    }
}

#pragma mark - Helper methods

- (void)subscribeForEvents
{
    self.sceneInteractor->meshUpdateStartEvent() += { "main.controller.mesh.update.start", [self](EARenderer::ID meshID) {
        self.cameraman->setIsEnabled(false);
    }};
    
    self.sceneInteractor->meshUpdateEvent() += { "main.controller.mesh.update", [self](EARenderer::ID meshID) {
        self.frequentEventsThrottle->attemptToPerformAction([=]() {
            [self.sceneEditorTabView showMeshWithID:meshID];
        });
    }};
    
    self.sceneInteractor->meshUpdateEndEvent() += { "main.controller.mesh.update.end", [self](EARenderer::ID meshID) {
        self.cameraman->setIsEnabled(true);
    }};
    
    self.sceneInteractor->meshSelectionEvent() += { "main.controller.mesh.select", [self](EARenderer::ID meshID) {
        [self.sceneObjectsTabView.meshesTab selectMeshWithID:meshID];
        [self.sceneEditorTabView showMeshWithID:meshID];
    }};
    
    self.sceneInteractor->meshDeselectionEvent() += { "main.controller.mesh.deselect", [self](EARenderer::ID meshID) {
         [self.sceneObjectsTabView.meshesTab deselectMeshWithID:meshID];
    }};
    
    self.sceneInteractor->allObjectsDeselectionEvent() += { "main.controller.deselect.all", [self]() {
        [self.sceneObjectsTabView.meshesTab deselectAll];
    }};
}

- (std::string)resourceDirectory {
    return std::string([[NSBundle mainBundle] resourcePath].UTF8String);
}

@end

