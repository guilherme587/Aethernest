# Diff Details

Date : 2025-07-20 21:41:15

Directory d:\\GODOT 3.6\\projetos\\Aethernest\\scripts

Total : 32 files,  743 codes, 135 comments, 279 blanks, all 1157 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [camera/CameraController.gd](/camera/CameraController.gd) | GDScript | 434 | 76 | 137 | 647 |
| [debug/CombatTester.gd](/debug/CombatTester.gd) | GDScript | 38 | 5 | 17 | 60 |
| [decoration/DecorationCatalog.gd](/decoration/DecorationCatalog.gd) | GDScript | 77 | 3 | 20 | 100 |
| [decoration/DecorationItem.gd](/decoration/DecorationItem.gd) | GDScript | 110 | 14 | 40 | 164 |
| [decoration/Tree.gd](/decoration/Tree.gd) | GDScript | 33 | 6 | 15 | 54 |
| [dragon/Dragon.gd](/dragon/Dragon.gd) | GDScript | 233 | 33 | 83 | 349 |
| [dragon/DragonBehavior.gd](/dragon/DragonBehavior.gd) | GDScript | 435 | 115 | 170 | 720 |
| [dragon/DragonPersonality.gd](/dragon/DragonPersonality.gd) | GDScript | 367 | 37 | 100 | 504 |
| [dragon/DragonProjectile.gd](/dragon/DragonProjectile.gd) | GDScript | 234 | 37 | 93 | 364 |
| [dragon/DragonStats.gd](/dragon/DragonStats.gd) | GDScript | 120 | 10 | 36 | 166 |
| [managers/DecorationManager.gd](/managers/DecorationManager.gd) | GDScript | 276 | 18 | 99 | 393 |
| [managers/DragonManager.gd](/managers/DragonManager.gd) | GDScript | 78 | 8 | 38 | 124 |
| [ui/CustomStatusBar.gd](/ui/CustomStatusBar.gd) | GDScript | 0 | 54 | 1 | 55 |
| [ui/DecorationUI.gd](/ui/DecorationUI.gd) | GDScript | 296 | 24 | 90 | 410 |
| [ui/DragonInfoUI.gd](/ui/DragonInfoUI.gd) | GDScript | 518 | 656 | 185 | 1,359 |
| [ui/UITheme.gd](/ui/UITheme.gd) | GDScript | 0 | 45 | 1 | 46 |
| [utils/Enums.gd](/utils/Enums.gd) | GDScript | 36 | 6 | 5 | 47 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\camera\\CameraController.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Ccamera%5CCameraController.gd) | GDScript | -430 | -76 | -136 | -642 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\decoration\\DecorationCatalog.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cdecoration%5CDecorationCatalog.gd) | GDScript | -77 | -3 | -20 | -100 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\decoration\\DecorationItem.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cdecoration%5CDecorationItem.gd) | GDScript | -110 | -14 | -40 | -164 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\decoration\\Tree.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cdecoration%5CTree.gd) | GDScript | -33 | -6 | -15 | -54 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\dragon\\Dragon.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cdragon%5CDragon.gd) | GDScript | -192 | -23 | -63 | -278 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\dragon\\DragonBehavior.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cdragon%5CDragonBehavior.gd) | GDScript | -204 | -33 | -72 | -309 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\dragon\\DragonPersonality.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cdragon%5CDragonPersonality.gd) | GDScript | -367 | -37 | -100 | -504 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\dragon\\DragonStats.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cdragon%5CDragonStats.gd) | GDScript | -105 | -9 | -31 | -145 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\managers\\DecorationManager.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cmanagers%5CDecorationManager.gd) | GDScript | -248 | -38 | -101 | -387 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\managers\\DragonManager.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cmanagers%5CDragonManager.gd) | GDScript | -76 | -5 | -35 | -116 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\ui\\CustomStatusBar.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cui%5CCustomStatusBar.gd) | GDScript | 0 | -54 | -1 | -55 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\ui\\DecorationUI.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cui%5CDecorationUI.gd) | GDScript | -154 | -26 | -49 | -229 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\ui\\DragonInfoUI.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cui%5CDragonInfoUI.gd) | GDScript | -511 | -637 | -182 | -1,330 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\ui\\UITheme.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cui%5CUITheme.gd) | GDScript | 0 | -45 | -1 | -46 |
| [d:\\GODOT 3.6\\projetos\\dragon\_mania\\scripts\\utils\\Enums.gd](/d:%5CGODOT%203.6%5Cprojetos%5Cdragon_mania%5Cscripts%5Cutils%5CEnums.gd) | GDScript | -35 | -6 | -5 | -46 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details