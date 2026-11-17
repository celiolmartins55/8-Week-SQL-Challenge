-- Removing NULL records within the customer_orders table
UPDATE customer_orders
SET exclusions = CASE
    WHEN exclusions LIKE 'null' THEN ''
    ELSE exclusions
    END,
	extras = CASE
    WHEN extras is NULL or extras LIKE 'null' THEN ''
    ELSE extras
	END;

-- Removing NULL values and standardising records within the runner_orders table
UPDATE runner_orders
SET pickup_time = CASE
    WHEN pickup_time = 'null' THEN ''
    ELSE pickup_time
	END,
	distance = CASE
	WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
    when distance LIKE 'null' THEN ''
    ELSE distance
    END,
    duration = CASE
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
    WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
    WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
    WHEN duration LIKE 'null' THEN ''
    ELSE duration
    END,
    cancellation = CASE
    WHEN cancellation LIKE 'null' OR cancellation IS NULL THEN ''
    ELSE cancellation
    END;

-- Altering the type of several columns
ALTER TABLE runner_orders
ALTER COLUMN pickup_time TYPE TIMESTAMP USING NULLIF(pickup_time, '')::TIMESTAMP,
ALTER COLUMN distance TYPE NUMERIC USING NULLIF(distance, '')::NUMERIC,
ALTER COLUMN duration TYPE INTEGER USING NULLIF(duration, '')::INTEGER;
