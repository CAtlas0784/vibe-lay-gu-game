"""
Extracts Traffic Lanes, Pedestrian Splines, Interiors, and Traffic Signals from
readable_world_dump_4229938_final.zip without unpacking the full 5.1 GB archive.
Produces high-performance, compact JSON caches in Ananta.Server/ClientData/4229938/World/.
"""

import sys
import os
import io
import json
import math
import csv
import zipfile
import time

ZIP_PATH = r"c:\Users\Phitchayut\Desktop\Drop asset\readable_world_dump_4229938_final.zip"
OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                       "Ananta.Server", "ClientData", "4229938", "World")

os.makedirs(OUT_DIR, exist_ok=True)

print(f"[EXTRACT] Reading from: {ZIP_PATH}")
print(f"[EXTRACT] Target output directory: {OUT_DIR}")

t0 = time.time()

with zipfile.ZipFile(ZIP_PATH, "r") as z:
    # -------------------------------------------------------------
    # 1. Extract Road Networks (Vehicles)
    # -------------------------------------------------------------
    road_sources = [
        ("city", "readable_world_dump_4229938_final/03_ZONEGRAPHS/full_json/vfc_1286_e108_h2b81bc528d8b6797.json"),
        ("airport", "readable_world_dump_4229938_final/03_ZONEGRAPHS/full_json/vfc_999_e28_hcec9b1c776a677f4.json"),
        ("longqi", "readable_world_dump_4229938_final/03_ZONEGRAPHS/full_json/vfc_997_e3_h859e50d46cdca6f9.json"),
    ]

    all_road_lanes = []
    spatial_grid = {}  # "cellX_cellZ" -> [globalLaneIndex]
    grid_size = 100.0  # 100 meter spatial buckets

    global_lane_counter = 0

    for region_name, zip_entry in road_sources:
        print(f"[ROAD] Processing {region_name} from {zip_entry}...")
        with z.open(zip_entry) as f:
            data = json.load(f)

        lanes = data.get("lanes", [])
        pts = data.get("lanePoints", [])
        tangents = data.get("laneTangentVectors", [])
        links = data.get("laneLinks", [])

        # Offset to map local destLaneIndex to globalLaneIndex
        base_lane_idx = global_lane_counter

        for local_id, lane in enumerate(lanes):
            tag_names = lane.get("tagNames", [])
            # Filter for vehicle road lanes
            is_vehicle = "Vehicle" in tag_names or "CapillaryRoad" in tag_names or "Freeway" in tag_names

            p_begin = lane.get("pointsBegin", 0)
            p_end = lane.get("pointsEnd", 0)
            lane_pts = pts[p_begin:p_end]
            if not lane_pts or len(lane_pts) < 2:
                continue

            lane_tangents = tangents[p_begin:p_end] if tangents else []

            # Gather outgoing and adjacent links
            l_begin = lane.get("linksBegin", 0)
            l_end = lane.get("linksEnd", 0)
            lane_links = links[l_begin:l_end] if links else []

            outgoing = []
            adjacent = []
            for link in lane_links:
                dest = link.get("destLaneIndex", -1)
                l_type = link.get("type", 0)
                if dest >= 0 and dest < len(lanes):
                    if l_type == 1:  # Outgoing
                        outgoing.append(base_lane_idx + dest)
                    elif l_type == 4:  # Adjacent (lane change)
                        adjacent.append(base_lane_idx + dest)

            # Determine speed limit: Freeway = 16.67 m/s (60km/h), Normal = 11.11 m/s (40km/h), Alley = 8.33 m/s (30km/h)
            if "Freeway" in tag_names:
                speed_limit = 16.67
            elif "VehicleAlley" in tag_names:
                speed_limit = 8.33
            else:
                speed_limit = 11.11

            # Compute bounding box
            xs = [p[0] for p in lane_pts]
            ys = [p[1] for p in lane_pts]
            zs = [p[2] for p in lane_pts]
            min_x, max_x = min(xs), max(xs)
            min_y, max_y = min(ys), max(ys)
            min_z, max_z = min(zs), max(zs)

            # Compact points: [[x, y, z], ...] rounded to 2 decimals
            compact_pts = [[round(p[0], 2), round(p[1], 2), round(p[2], 2)] for p in lane_pts]
            compact_tangents = [[round(t[0], 3), round(t[1], 3), round(t[2], 3)] for t in lane_tangents] if lane_tangents else []

            g_idx = global_lane_counter
            global_lane_counter += 1

            lane_entry = {
                "id": g_idx,
                "region": region_name,
                "width": round(lane.get("width", 4.0), 1),
                "speed": speed_limit,
                "turn": lane.get("turnDirectionName", "Straight"),
                "tags": tag_names,
                "pts": compact_pts,
                "tangents": compact_tangents,
                "next": outgoing,
                "adj": adjacent,
                "bbox": [round(min_x, 1), round(min_y, 1), round(min_z, 1),
                         round(max_x, 1), round(max_y, 1), round(max_z, 1)]
            }
            all_road_lanes.append(lane_entry)

            # Register in spatial grid cells
            min_cx = int(math.floor(min_x / grid_size))
            max_cx = int(math.floor(max_x / grid_size))
            min_cz = int(math.floor(min_z / grid_size))
            max_cz = int(math.floor(max_z / grid_size))

            for cx in range(min_cx, max_cx + 1):
                for cz in range(min_cz, max_cz + 1):
                    ckey = f"{cx}_{cz}"
                    if ckey not in spatial_grid:
                        spatial_grid[ckey] = []
                    spatial_grid[ckey].append(g_idx)

    road_cache = {
        "metadata": {
            "totalLanes": len(all_road_lanes),
            "gridSize": grid_size,
            "totalGridCells": len(spatial_grid)
        },
        "spatialGrid": spatial_grid,
        "lanes": all_road_lanes
    }

    road_out_path = os.path.join(OUT_DIR, "RoadNetwork.json")
    print(f"[ROAD] Writing {len(all_road_lanes)} road lanes to {road_out_path}...")
    with open(road_out_path, "w", encoding="utf-8") as out_f:
        json.dump(road_cache, out_f, separators=(",", ":"))
    print(f"[ROAD] Done! File size: {os.path.getsize(road_out_path) / 1024 / 1024:.2f} MB")

    # -------------------------------------------------------------
    # 2. Extract Pedestrian Sidewalks & Crosswalks
    # -------------------------------------------------------------
    ped_source = "readable_world_dump_4229938_final/03_ZONEGRAPHS/full_json/vfc_1000_e8_hfef331e26e35309d.json"
    print(f"[PED] Processing pedestrian graph from {ped_source}...")
    with z.open(ped_source) as f:
        data = json.load(f)

    ped_lanes = data.get("lanes", [])
    ped_pts = data.get("lanePoints", [])
    ped_tangents = data.get("laneTangentVectors", [])
    ped_links = data.get("laneLinks", [])

    compact_ped_lanes = []
    ped_spatial_grid = {}

    for local_id, lane in enumerate(ped_lanes):
        p_begin = lane.get("pointsBegin", 0)
        p_end = lane.get("pointsEnd", 0)
        lane_pts = ped_pts[p_begin:p_end]
        if not lane_pts or len(lane_pts) < 2:
            continue

        tag_names = lane.get("tagNames", [])
        compact_pts = [[round(p[0], 2), round(p[1], 2), round(p[2], 2)] for p in lane_pts]

        xs = [p[0] for p in lane_pts]
        zs = [p[2] for p in lane_pts]
        min_x, max_x = min(xs), max(xs)
        min_z, max_z = min(zs), max(zs)

        ped_entry = {
            "id": local_id,
            "tags": tag_names,
            "pts": compact_pts,
            "isCrosswalk": "Crosswalk" in tag_names
        }
        compact_ped_lanes.append(ped_entry)

        min_cx = int(math.floor(min_x / grid_size))
        max_cx = int(math.floor(max_x / grid_size))
        min_cz = int(math.floor(min_z / grid_size))
        max_cz = int(math.floor(max_z / grid_size))

        for cx in range(min_cx, max_cx + 1):
            for cz in range(min_cz, max_cz + 1):
                ckey = f"{cx}_{cz}"
                if ckey not in ped_spatial_grid:
                    ped_spatial_grid[ckey] = []
                ped_spatial_grid[ckey].append(local_id)

    ped_cache = {
        "metadata": {
            "totalLanes": len(compact_ped_lanes),
            "gridSize": grid_size,
            "totalGridCells": len(ped_spatial_grid)
        },
        "spatialGrid": ped_spatial_grid,
        "lanes": compact_ped_lanes
    }

    ped_out_path = os.path.join(OUT_DIR, "PedestrianNetwork.json")
    print(f"[PED] Writing {len(compact_ped_lanes)} pedestrian lanes to {ped_out_path}...")
    with open(ped_out_path, "w", encoding="utf-8") as out_f:
        json.dump(ped_cache, out_f, separators=(",", ":"))
    print(f"[PED] Done! File size: {os.path.getsize(ped_out_path) / 1024 / 1024:.2f} MB")

    # -------------------------------------------------------------
    # 3. Extract Interiors & Shops
    # -------------------------------------------------------------
    print("[INTERIORS] Processing interiors from interiors_full.csv...")
    interiors_list = []
    interior_spatial_grid = {}

    with z.open("readable_world_dump_4229938_final/00_INDEX/interiors_full.csv") as f:
        reader = csv.reader(io.TextIOWrapper(f, encoding="utf-8-sig"))
        header = next(reader)
        for row in reader:
            indoor_id = row[2]
            name = row[3]
            sector = row[4]
            wx_s, wy_s, wz_s = row[7], row[8], row[9]
            if not wx_s or not wy_s or not wz_s:
                continue
            try:
                wx = round(float(wx_s), 2)
                wy = round(float(wy_s), 2)
                wz = round(float(wz_s), 2)
            except ValueError:
                continue

            idx = len(interiors_list)
            entry = {
                "id": int(indoor_id) if indoor_id.isdigit() else 0,
                "name": name,
                "sector": sector,
                "pos": [wx, wy, wz]
            }
            interiors_list.append(entry)

            cx = int(math.floor(wx / grid_size))
            cz = int(math.floor(wz / grid_size))
            ckey = f"{cx}_{cz}"
            if ckey not in interior_spatial_grid:
                interior_spatial_grid[ckey] = []
            interior_spatial_grid[ckey].append(idx)

    interiors_cache = {
        "metadata": {
            "totalInteriors": len(interiors_list),
            "gridSize": grid_size
        },
        "spatialGrid": interior_spatial_grid,
        "interiors": interiors_list
    }

    interiors_out_path = os.path.join(OUT_DIR, "Interiors.json")
    print(f"[INTERIORS] Writing {len(interiors_list)} interiors to {interiors_out_path}...")
    with open(interiors_out_path, "w", encoding="utf-8") as out_f:
        json.dump(interiors_cache, out_f, indent=2, ensure_ascii=False)
    print(f"[INTERIORS] Done! File size: {os.path.getsize(interiors_out_path) / 1024:.2f} KB")

    # -------------------------------------------------------------
    # 4. Extract Traffic Signals & Intersections
    # -------------------------------------------------------------
    print("[SIGNALS] Processing traffic lights and intersections...")
    with z.open("readable_world_dump_4229938_final/04_WORLD_JSON/full_json/vfc_47_e11_h7140c25172fd7615.json") as f:
        lights_raw = json.load(f).get("TrafficLights", [])
    with z.open("readable_world_dump_4229938_final/04_WORLD_JSON/full_json/vfc_47_e13_h64c11d788d8b4dd9.json") as f:
        inter_raw = json.load(f).get("interInfos", [])

    compact_lights = []
    for l in lights_raw:
        pos = l.get("position", {})
        fwd = l.get("forward", {})
        compact_lights.append({
            "handle": l.get("trafficLightHandle", 0),
            "inter": l.get("inter", -1),
            "zbr": l.get("zbr", -1),
            "pos": [round(pos.get("x", 0), 2), round(pos.get("y", 0), 2), round(pos.get("z", 0), 2)],
            "fwd": [round(fwd.get("x", 0), 3), round(fwd.get("y", 0), 3), round(fwd.get("z", 0), 3)],
        })

    compact_inter = []
    for it in inter_raw:
        compact_inter.append({
            "id": it.get("intersection", 0),
            "zebras": [z.get("zebra") for z in it.get("zebraConnector", [])]
        })

    signals_cache = {
        "lights": compact_lights,
        "intersections": compact_inter
    }

    signals_out_path = os.path.join(OUT_DIR, "TrafficSignals.json")
    print(f"[SIGNALS] Writing {len(compact_lights)} lights and {len(compact_inter)} intersections to {signals_out_path}...")
    with open(signals_out_path, "w", encoding="utf-8") as out_f:
        json.dump(signals_cache, out_f, indent=2, ensure_ascii=False)
    print(f"[SIGNALS] Done! File size: {os.path.getsize(signals_out_path) / 1024:.2f} KB")

t_elapsed = time.time() - t0
print(f"[ALL COMPLETE] World and Traffic data extraction completed in {t_elapsed:.2f} seconds!")
