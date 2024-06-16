class_name GKObjectEnums

## Approach behavior.
##
## STATIC: Do nothing.
## SHOOT: Stand and shoot at the katamari. (Functionally identical to STATIC)
## FLEE: Run from the katamari.
## CHARGE: Run towards the katamari.
## CLOWN: Jump on top of the katamari, then fall down after a few seconds.
enum ApproachBehavior {STATIC, SHOOT, FLEE, CHARGE, CLOWN}

## Physics behavior.
##
## STATIC: Stay still.
## GRAVITY: Falls as a physics object.
## PATH: Follows a path.
## ROAM: Roams an area.
## LAUNCH: If the parent object is bumped into, launches using the direction of a Vector3.
enum PhysicsBehavior {STATIC, GRAVITY, ROAM, PATH, LAUNCH}
