# Mars Colony UI System (v2)

## Goals
- Strong readability on mobile portrait (1080x1920 target).
- Clear information hierarchy for resources, warnings, and actions.
- Reusable visual language across all gameplay panels.

## Visual Direction
- Palette: cold industrial blues for base UI, warm accents for alerts/rewards.
- Contrast: dark panel surfaces with bright text and controlled accent colors.
- Depth: soft panel shadows, rounded corners, consistent border treatment.

## Core Tokens
- Base panel: `Color(0.066, 0.102, 0.153, 0.96)`
- Panel border: `Color(0.231, 0.459, 0.627, 1.0)`
- Primary text: `Color(0.816, 0.922, 1.0, 1.0)`
- Button normal: `Color(0.098, 0.173, 0.247, 1.0)`
- Button hover: `Color(0.133, 0.259, 0.365, 1.0)`
- Disabled text: `Color(0.565, 0.627, 0.710, 1.0)`

## Typographic Scale
- Page title: 34-42
- Section header: 20-24
- Primary data label: 17-24
- Card metadata: 13-15

## Layout Rules
- Main panel padding: 20 px.
- Inter-section spacing: 12-16 px.
- Minimum action button height: 52 px.
- Bottom action bars should be at least 116 px high for touch clarity.

## Components Updated
- `ui/themes/MarsTheme.tres`
- `ui/TopBar.tscn`
- `ui/BuildMenu.tscn`
- `ui/BuildingInfoPanel.tscn`
- `ui/EventNotification.tscn`
- `ui/TechnologyTree.tscn`
- `ui/MissionTracker.tscn`
- `ui/ManagerSelectionPanel.tscn`
- `ui/BuildingNode.tscn`
- `ui/TechNode.tscn`

## Integration Note
- `scripts/TopBar.gd` now resolves notification UI via `EventNotification` node name.
