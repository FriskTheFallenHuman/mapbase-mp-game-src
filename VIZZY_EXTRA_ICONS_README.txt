
Hello. This is my attempt to make Hammer more bearable to use with more icons for various entitys.
My thinking is any icon is better than a blank one!

//CHANGELOG//
updated for the official mapbase 7.1.1 version (no longer for 7.0)
fixed npc_fisherman model being barney for some reason -volvo/blixi pls fix
added output OnCrashed (not OnCrash like in earlier versions, whoopsies) for info_target_gunshipcrash (recommended by xblah)
env_smokestack, phys_thruster and phys_torque have been changed to a grey directional arrow model (also by ficool2) for better directional placement!
added an icon for env_rotorwash

--//INSTALL INSTRUCTIONS//--
Ideally you can just copy this shared_misc folder over the one in sourcemods/mapbase_shared/shared_misc/bin 

Or manually copy the base.fgd / halflife2.fgd over the ones in:	sourcemods/mapbase_shared/shared_misc/bin 
And copy the materials/models folders over your own mods or the new icons will show up as checkerboard missing textures.
(remember to do this again if you are upgrading from a previous version)

If something breaks or you don't like it, simply redownload the official mapbase release and overwrite the .fgds with the originals.


//CREDITS//
Id like to credit the following people:

Ficool2:
to my knowledge all icons in the editor-ficool folder were created by them. I painstakingly copy/pasted each icon from their tf2 ultimate .fgd (downloaded from tf2maps.net) over to the mapbase .fgd 
I edited and reused a few of their icons as well.

Blixibon:
I edited and reused a few of their mapbase specific icons such as logic_script and damage_info for some example.

TeamSpen210:
The icon for some entitys like point_entity_finder are by them (afaik), and I based the icon point_advanced_finder (a similiar mapbase entity) off of it as well. 

Vizzys:
Yep thats me, I wrote this. And I made the bad icons.


//ADDITIONAL INFO//
Some entities such as env_splash, env_dustpuff, env_citadel_energy_core and env_flare cannot have custom icons because the scale keyvalue parameter affects the icons and makes them super huge. (a hammer bug or more likely oversight by valve)
Another hammer feature/bug is is if the entity supports a color value it will change the icons color as well making it potentially unreadable. This can really only be fixed by making the icon an outline only AFAIK.
The closed caption logo used for env_closecaption is public domain.

Entitys I learned are not in mapbase .fgd's for whatever reasons and you may want to add someday:
commentary_auto 
prop_detail_sprite
point_commentary_node
env_detail_controller


//END NOTES//
Lastly Ive included the photoshop .psd file source of the icons Ive created and/or edited. 
As well as the hammer font source .psd file. It is based on blixibons work. I merely cut the characters into individual letters, numbers, and common entity prefixes.

Thats everything, go away now.