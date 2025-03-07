--[=[
	@class Types
	This module exports a list of types that can be used for typechecking
]=]

export type ZombieAnimations = {
	Attack: string,
}
export type RaceResults = {
	TypedString: string,
	Incorrect: number,
	Chain: number,
	WPM: number,
	PlayerName: string,
	Placement: number,
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
return nil
