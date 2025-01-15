# Mineplex Studio Map Rotation Action

This GitHub Action allows you to rotate maps in the active pool for Mineplex Studio. It enables you to swap a specified number of maps in the active pool, automating the process through a simple GitHub Action.

## Inputs

### `count` (required)

- **Description**: The number of maps to swap in the active pool.
- **Type**: `number`
- **Default**: `1`
- **Required**: `true`

## Outputs

### `COMMIT_MSG`

- **Description**: The commit message generated after rotating the maps.
- **Type**: `string`

## Usage

### Example Workflow
```yaml
name: Mineplex Studio Map Rotation Action
on:
  schedule:
    - cron: '0 0 * * 0'  # Runs every 2 weeks on Sunday at midnight (UTC)

jobs:
  swap-maps:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Rotate maps
        id: swap_maps
        uses: BillyDotWS/map-rotation@v1
        with:
          count: 12

      - name: Create a pull request
        uses: peter-evans/create-pull-request@v3
        with:
          title: "feature: rotate the current map pool"
          body: "${{ steps.swap_maps.outputs.COMMIT_MSG }}"
          base: master
          branch: "update-maps-${{ github.run_id }}"
```