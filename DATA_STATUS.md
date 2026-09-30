# Data status

All ability and NPC records in `data/` are **imported from the original Tamed database** (Tamed by moody).

They are **not** verified for WoW: Forever.

Do not treat Classic/TBC spell IDs, NPC IDs, map IDs, or coordinates as automatically correct for Forever.

| Layer | Source | Forever status |
| --- | --- | --- |
| Ability keys, ranks, spell IDs, pet levels, training costs, families | Original Tamed `TameableAbilities.lua` | Imported, requires in-game verification |
| NPC IDs, names, levels, families, diets, types, zone IDs, ui_map_id, coords | Original Tamed `TameableNPCs.lua` | Imported, requires in-game verification |
| Runtime spell names/icons | `C_Spell` when the client returns data | Overlay only; static rows are never deleted |
| Runtime location names | `C_Map.GetAreaInfo` / `C_Map.GetMapInfo` when available | Overlay only; NPC rows are never deleted |

No Forever-specific NPC, spell, coordinate, or family values were invented for this port.
