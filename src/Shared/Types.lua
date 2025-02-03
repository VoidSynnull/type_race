--[=[
	@class Types
	This module exports a list of types that can be used for typechecking
]=]

export type ZombieAnimations = {
	Attack: string,
}
export type ZombieData = {
	Attack: number,
	Word: string,
	AttackSpeed: number,
	Speed: number,
	Animations: ZombieAnimations,
	MoveTo: RBXScriptConnection,
}
export type AnimationPlayer = {
	PlayTrack: (
		self: AnimationPlayer,
		TrackName: string,
		Speed: number?,
		FadeTime: number?,
		Weight: number?,
		StopFadeTime: number?
	) -> (),

	GetTrack: (self: AnimationPlayer, TrackName: string) -> AnimationTrack,
}
export type Zombie = {
	Data: ZombieData,
	AnimationPlayer: AnimationPlayer,
}

return nil
