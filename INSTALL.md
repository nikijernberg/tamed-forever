# Installation — Tamed Forever

Folder name must be `Tamed_Forever` and must contain `Tamed_Forever.toc`.

## Forever client path

Reported for the Forever beta:

```
World of Warcraft\_classic_beta_\Interface\AddOns\Tamed_Forever\
```

If the launcher uses another directory (`_classic_ptr_`, `retail`, etc.), install there instead.

## Steps

1. Copy the `Tamed_Forever` folder to `Interface\AddOns\Tamed_Forever\`.
2. Enable **Tamed Forever** on the AddOns list.
3. In game: `/tamed`

The ability database, NPC database, AceGUI, and LibDBIcon are already included. They are the original Tamed files, copied unchanged. No NPC IDs, spell IDs, or coordinates were invented.

`copy-imported-data.ps1` is only for refreshing those files from a local Tamed checkout. It is not required to load the addon.

## In-game test plan (requires the Forever client)

1. Install addon.
2. Launch WoW: Forever.
3. Check AddOns list for Tamed Forever.
4. `/reload`
5. `/tamed`
6. Open and close the UI.
7. Browse abilities.
8. Browse ranks.
9. Select an NPC.
10. Use Show on Map.
11. Hover map pin.
12. `/tamed clear`
13. Hover a tameable NPC.
14. Check tooltip information.
15. Test minimap icon.
16. Test saved settings (`/reload` and confirm options persist).
17. `/tamed debug`
