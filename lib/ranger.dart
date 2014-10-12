library ranger;

import 'dart:html' as Html;
import 'dart:web_gl' as WebGL;
import 'dart:math' as math;
import 'dart:collection';
import 'dart:convert' show JSON;
import "dart:typed_data";
import "dart:async";

import 'package:vector_math/vector_math.dart';
import 'package:tweenengine/tweenengine.dart' as UTE;
import 'package:event_bus/event_bus.dart';

// ----------------------------------------------------------------------
// Resources
// ----------------------------------------------------------------------
part 'ranger/resources/base_resources.dart';
part 'ranger/resources/image_loader.dart';

// ----------------------------------------------------------------------
// Physics
// ----------------------------------------------------------------------
part 'ranger/physics/velocity.dart';
part 'ranger/physics/direction.dart';

// ----------------------------------------------------------------------
// Sprites
// ----------------------------------------------------------------------
part 'ranger/sprites/sprite_sheet.dart';
part 'ranger/sprites/sprite_sheet_image.dart';
part 'ranger/sprites/sprite_image.dart';
part 'ranger/sprites/sprite_filtered_image.dart';
part 'ranger/sprites/sprite_base.dart';
part 'ranger/sprites/sprite.dart';
part 'ranger/sprites/canvas_sprite.dart';

// ----------------------------------------------------------------------
// Geometry
// ----------------------------------------------------------------------
part 'ranger/geometry/point.dart';
part 'ranger/geometry/size.dart';
part 'ranger/geometry/rectangle.dart';
part 'ranger/geometry/vector2p.dart';
part 'ranger/geometry/polygon.dart';
part 'ranger/geometry/custom_polygon.dart';
part 'ranger/geometry/square.dart';
part 'ranger/geometry/circle.dart';
part 'ranger/geometry/triangle.dart';

// ----------------------------------------------------------------------
// Nodes
// ----------------------------------------------------------------------
part 'ranger/nodes/node_with_skew.dart';
part 'ranger/nodes/base_node.dart';
part 'ranger/nodes/node.dart';
part 'ranger/nodes/text_node.dart';
part 'ranger/nodes/empty_node.dart';
part 'ranger/nodes/group_node.dart';

// ----------------------------------------------------------------------
// Particles
// ----------------------------------------------------------------------
part 'ranger/particles/systems/particle_system.dart';
part 'ranger/particles/systems/basic_particle_system.dart';
part 'ranger/particles/systems/moderate_particle_system.dart';
part 'ranger/particles/particle.dart';
part 'ranger/particles/variance.dart';
part 'ranger/particles/particlesystem_visual.dart';
part 'ranger/particles/activators/randomvalue_particle_activator.dart';
part 'ranger/particles/activators/simple_particle_activator.dart';
part 'ranger/particles/activators/particle_activation.dart';
part 'ranger/particles/activators/activation_data.dart';

part 'ranger/particles/particle/simple_particle.dart';
part 'ranger/particles/particle/positional_particle.dart';
part 'ranger/particles/particle/color_swirly_particle.dart';
part 'ranger/particles/particle/universal_particle.dart';
part 'ranger/particles/particle/tween_particle.dart';

part 'ranger/particles/behaviors/particle_color_behavior.dart';
part 'ranger/particles/behaviors/particle_scale_behavior.dart';
part 'ranger/particles/behaviors/particle_rotation_behavior.dart';

// ----------------------------------------------------------------------
// Animations use Universal Tween Engine
// ----------------------------------------------------------------------
part 'ranger/animation/tween_animation.dart';

// ----------------------------------------------------------------------
// Rendering
// ----------------------------------------------------------------------
part 'ranger/rendering/draw_context.dart';
part 'ranger/rendering/draw_canvas.dart';
part 'ranger/rendering/draw_webgl.dart';
part 'ranger/rendering/colors.dart';

// ----------------------------------------------------------------------
// Scenes
// ----------------------------------------------------------------------
part 'ranger/nodes/scenes/scene.dart';
part 'ranger/nodes/scenes/boot_scene.dart';
part 'ranger/nodes/scenes/basic_scene.dart';
part 'ranger/nodes/scenes/anchored_scene.dart';
part 'ranger/nodes/scenes/scene_anchor_node.dart';
part 'ranger/nodes/scenes/scene_manager.dart';

part 'ranger/nodes/scenes/transitions/instant.dart';
part 'ranger/nodes/scenes/transitions/transition_scene.dart';
part 'ranger/nodes/scenes/transitions/move_in_from.dart';
part 'ranger/nodes/scenes/transitions/slide_in.dart';
part 'ranger/nodes/scenes/transitions/rotate_and_zoom.dart';
part 'ranger/nodes/scenes/transitions/shrink_grow.dart';
part 'ranger/nodes/scenes/transitions/fan_in_fan_out.dart';

// ----------------------------------------------------------------------
// Layers
// ----------------------------------------------------------------------
part 'ranger/nodes/layers/layer.dart';
part 'ranger/nodes/layers/layer_cascade.dart';
part 'ranger/nodes/layers/background_layer.dart';
part 'ranger/nodes/layers/overlay_layer.dart';
part 'ranger/nodes/layers/layer_multiplex.dart';

// ----------------------------------------------------------------------
// Behaviors
// ----------------------------------------------------------------------
part 'ranger/nodes/behaviors/scale_behavior.dart';
part 'ranger/nodes/behaviors/skew_behavior.dart';
part 'ranger/nodes/behaviors/rotation_behavior.dart';
part 'ranger/nodes/behaviors/positional_behavior.dart';
part 'ranger/nodes/behaviors/aabbox_behavior.dart';
part 'ranger/nodes/behaviors/visibility_behavior.dart';
part 'ranger/nodes/behaviors/grouping_behavior.dart';

// ----------------------------------------------------------------------
// Mixins
// ----------------------------------------------------------------------
part 'ranger/mixins/uniform_scale_mixin.dart';
part 'ranger/mixins/color4_mixin.dart';
part 'ranger/mixins/rgba_cascade_mixin.dart';
part 'ranger/mixins/mouse_input_mixin.dart';
part 'ranger/mixins/keyboard_input_mixin.dart';
part 'ranger/mixins/touch_input_mixin.dart';

// ----------------------------------------------------------------------
// Cores
// ----------------------------------------------------------------------
part 'ranger/core/timing/timer.dart';
part 'ranger/core/timing/timing_target.dart';
part 'ranger/core/timing/scheduler.dart';
part 'ranger/core/application.dart';

part 'ranger/core/pooling/component.dart';
part 'ranger/core/pooling/object_pool.dart';
part 'ranger/core/pooling/read_only_bag.dart';
part 'ranger/core/pooling/bag.dart';

part 'ranger/core/core.dart';
part 'ranger/core/browser.dart';
part 'ranger/core/affine_transform.dart';

// ----------------------------------------------------------------------
// Misc: Utilities, config
// ----------------------------------------------------------------------
part 'ranger/utilities/logging.dart';
part 'ranger/utilities/math.dart';

part 'ranger/config.dart';
