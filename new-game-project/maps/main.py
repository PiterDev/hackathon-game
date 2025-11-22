import json

bar_len = 2.0

note_len = 1.0

bar_amt = 85

start = 4.0

timestamps = []

curr_stamp = start

pattern = [0.5,0.5,0.5]

pattern_id = 0

for i in range(1,bar_amt):

    for p in pattern:
        
        

        timestamps.append(curr_stamp)
        curr_stamp += note_len * p

    curr_stamp = i*bar_len + start
    

with open('data.json', 'w') as f:
    json.dump(timestamps, f)

