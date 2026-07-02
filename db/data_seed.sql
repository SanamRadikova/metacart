-- ==========================================
-- Seed Data for MetaCart Core Tables
-- All cultural groups stored in snake_case to match schema.
-- HDL thresholds follow REFERENCE_RANGES.md (conservative AHA 2023 levels).
-- ==========================================

-- 1. LAB UNITS REFERENCE
-- Converts various international units to standard Engine units (e.g., mg/dL for glucose)
INSERT INTO lab_units_reference (biomarker, source_unit, conversion_type, conversion_factor) VALUES
('glucose', 'mmol/L', 'multiply', 18.0182),
('glucose', 'mg/dL', 'multiply', 1.0),
('hba1c', 'mmol/mol', 'formula', 1.0), -- Handled in Go layer
('hba1c', '%', 'multiply', 1.0),
('tg', 'mmol/L', 'multiply', 88.57),
('tg', 'mg/dL', 'multiply', 1.0),
('hdl', 'mmol/L', 'multiply', 38.67),
('hdl', 'mg/dL', 'multiply', 1.0),
('ldl', 'mmol/L', 'multiply', 38.67),
('ldl', 'mg/dL', 'multiply', 1.0),
('hs_crp', 'mg/L', 'multiply', 1.0),
('tsh', 'mIU/L', 'multiply', 1.0);

-- 2. REFERENCE RANGES
-- All cultural_group values in snake_case. 'general' is the fallback for any culture without a custom row.
-- 'green' is optimal, 'yellow' is warning, 'orange' is dysregulated.
-- Age range for the seed: 25-65 (per REFERENCE_RANGES.md). For users aged 18-25, the engine falls back to this same 25-65 range.
INSERT INTO reference_ranges (biomarker, cultural_group, gender, green_min, green_max, yellow_min, yellow_max, orange_min, orange_max) VALUES
-- Fasting Glucose
('glucose', 'standard_american', 'any', 70, 90, 91, 100, 101, 125),
('glucose', 'south_asian', 'any', 70, 85, 86, 95, 96, 125), -- Stricter threshold for South Asian cohort
('glucose', 'general', 'any', 70, 90, 91, 100, 101, 125),
-- HbA1c
('hba1c', 'standard_american', 'any', 4.0, 5.2, 5.3, 5.6, 5.7, 6.4),
('hba1c', 'south_asian', 'any', 4.0, 5.0, 5.1, 5.4, 5.5, 6.4),
('hba1c', 'general', 'any', 4.0, 5.2, 5.3, 5.6, 5.7, 6.4),
-- Triglycerides
('tg', 'standard_american', 'any', 0, 90, 91, 150, 151, 500),
('tg', 'general', 'any', 0, 99, 100, 149, 150, 500),
-- HDL (Gender differences, conservative thresholds from REFERENCE_RANGES.md)
-- Female: >50 stable, 40-50 attention, <40 deviation
-- Male:   >40 stable, 35-40 attention, <35 deviation
('hdl', 'standard_american', 'female', 50, 150, 40, 49, 0, 39),
('hdl', 'standard_american', 'male', 40, 150, 35, 39, 0, 34),
('hdl', 'general', 'female', 50, 150, 40, 49, 0, 39),
('hdl', 'general', 'male', 40, 150, 35, 39, 0, 34),
-- hs-CRP (Inflammation)
('hs_crp', 'standard_american', 'any', 0.0, 0.9, 1.0, 3.0, 3.1, 10.0),
('hs_crp', 'general', 'any', 0.0, 0.9, 1.0, 3.0, 3.1, 10.0),
-- TSH (Thyroid)
('tsh', 'standard_american', 'any', 0.5, 2.0, 2.1, 4.0, 4.1, 10.0),
('tsh', 'general', 'any', 0.5, 2.0, 2.1, 4.0, 4.1, 10.0);

-- 3. CULTURAL FOOD PATTERNS
-- All cultures in snake_case to align with users.cultural_group CHECK.
INSERT INTO cultural_food_patterns (culture, pattern_name, typical_ingredients, glycemic_impact, protective, trigger) VALUES
('south_asian', 'White Rice Staple', '["white basmati rice", "naan", "roti"]', 'high', false, true),
('south_asian', 'Lentil Base', '["moong dal", "chana dal", "masoor dal"]', 'moderate', true, false),
('eastern_european', 'Potato Base', '["potatoes", "sour cream", "white bread"]', 'high', false, true),
('eastern_european', 'Fermented Veggies', '["sauerkraut", "kefir", "pickles"]', 'low', true, false),
('latino', 'Corn and Beans', '["corn tortillas", "black beans", "pinto beans"]', 'moderate', true, false),
('latino', 'Refried and Sweet', '["refried beans (lard)", "pan dulce", "sodas"]', 'high', false, true),
('african_american', 'Soul Greens', '["collard greens", "black-eyed peas", "sweet potato"]', 'low', true, false),
('african_american', 'Fried Proteins', '["fried chicken", "mac and cheese", "cornbread"]', 'high', false, true),
('east_asian', 'Rice and Greens', '["brown rice", "bok choy", "tofu", "miso"]', 'low', true, false),
('east_asian', 'Noodle and Dim Sum', '["white noodles", "dim sum", "sweetened sauces"]', 'high', false, true),
('standard_american', 'SAD Diet', '["white bread", "processed cheese", "soda", "chips"]', 'high', false, true),
('standard_american', 'Mediterranean Inspired', '["olive oil", "leafy greens", "salmon", "berries"]', 'low', true, false);

-- 4. PRODUCTS CATALOG (Mock Seed)
INSERT INTO products_catalog (product_name, product_category, trade_units, is_nutraceutical, profile_tags, source) VALUES
('Organic Pasture-Raised Eggs', 'proteins', '{"low": "GV Eggs 12ct", "mid": "Pete & Gerrys 12ct", "high": "Vital Farms 12ct"}', false, '[1, 2, 3, 4, 5]', 'Manual'),
('Wild Caught Alaskan Salmon', 'proteins', '{"low": "Canned Pink Salmon", "mid": "Frozen Sockeye", "high": "Fresh King Salmon"}', false, '[1, 2, 3]', 'Manual'),
('Organic Extra Virgin Olive Oil', 'fats_oils', '{"low": "Pompeian 16oz", "mid": "California Olive Ranch", "high": "Lucini Premium"}', false, '[1, 2, 3, 4, 5]', 'Manual'),
('Berberine 500mg', 'supplements', '{"low": "Generic Berberine", "mid": "Thorne Berberine", "high": "Thorne Berberine"}', true, '[1]', 'Manual'),
('Avocado Oil', 'fats_oils', '{"low": "Chosen Foods Blend", "mid": "Chosen Foods 100%", "high": "Primal Kitchen"}', false, '[1, 2, 3, 4, 5]', 'Manual'),
('Organic Spinach', 'vegetables', '{"low": "Frozen Spinach 10oz", "mid": "Fresh Spinach Bag", "high": "Organic Clamshell"}', false, '[1, 2, 3, 4, 5]', 'Manual');
