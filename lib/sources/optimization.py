import subprocess
import json
import numpy as np
from stochopy.optimize import minimize

def run_js_function(lat, long, alt, timeoffset):
    # Command to run the JavaScript script with Node.js
    command = ['node', 'lib/sources/eclipse_explorer_py.jsx', str(lat), str(long), str(alt), str(timeoffset)]

    # Execute the command
    result = subprocess.run(command, capture_output=True, text=True)

    # Check if the command ran successfully
    if result.returncode == 0:
        # Parse the output
        output = json.loads(result.stdout)
        return output
    else:
        # Handle errors if needed
        print("Error:", result.stderr)
        return None

# Example usage
latitude = 37.7749
longitude = -122.4194
altitude = 0.0
time_offset = 0.0

#output = run_js_function(latitude, longitude, altitude, time_offset)


# Define your objective function
def calculate_obscuration(lat, long, alt):
    output = run_js_function(lat, long, alt, 0)
    if output is not None and output['obscuration'] != '':
        return float(output['obscuration'])
    else:
        return 0


# LAT: -39, 60)
x = minimize(rosenbrock, bounds, method="cmaes", options={"maxiter": 100, "popsize": 10, "seed": 0})

# Find the latitude with maximum obscuration for each longitude in the US
def find_max_obscuration_latitudes():
    max_obscuration_latitudes = []
    
    # Iterate over all possible longitudes in the contiguous United States
    for long in range(-160, -10):
        print("Processing longitude:", long)
        # Perform gradient descent to find latitude and altitude with maximum obscuration for the current longitude
        best_lat, best_alt, max_obscuration = gradient_descent_for_longitude(long)
        
        # Append the latitude with maximum obscuration for the current longitude
        max_obscuration_latitudes.append((best_lat, long, best_alt, max_obscuration))
    
    return max_obscuration_latitudes

# Find latitudes with maximum obscuration for each longitude
max_obscuration_latitudes = find_max_obscuration_latitudes()

# Print the results
for latitude, longitude, altitude, obscuration in max_obscuration_latitudes:
    print(f"Latitude with max obscuration for longitude {longitude} at altitude {altitude}: {latitude} (Obscuration: {obscuration})")


# TODO: GOTTA PLAY AROUND WITH ALT VALUES