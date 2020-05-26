import 'package:json_api/src/routing/composite_routing.dart';
import 'package:json_api/src/routing/standard_routes.dart';

/// The standard (recommended) URI design
class StandardRouting extends CompositeRouting {
  StandardRouting([Uri base])
      : super(StandardCollectionRoute(base), StandardResourceRoute(base),
            StandardRelatedRoute(base), StandardRelationshipRoute(base));
}
