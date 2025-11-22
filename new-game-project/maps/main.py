import json

bar_len = 2.0

note_len = 0.5

bar_amt = 85

timestamps = []

curr_stamp = 0.0

pattern = [1,0.5,0.5,1,1]

pattern_id = 0

for i in range(bar_amt):

    for p in pattern:
        curr_stamp += note_len * p
        timestamps.append(curr_stamp)
    

with open('data.json', 'w') as f:
    json.dump(timestamps, f)

