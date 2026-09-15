# ConfigDump import — build 4229938 (V5)

- Source: user supplied `ConfigDump.zip` / `ConfigDump_v2`.
- Imported JSON tables: 1512.
- Existing server-derived catalogs that have no source table with the same filename are retained.
- Runtime item bootstrap now reads the imported `ConsumableConfig.json` directly.
- The imported dump reports serialization issues in some source tables; V5 preserves them as dumped instead of inventing replacement records.
