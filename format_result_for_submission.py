import numpy as np
import json
import argparse

def main(result_upload_file, submission_file):
    submission = []
    with open(result_upload_file, "r") as f:
        submission_data = json.load(f)
    #print(submission_data)
    for data in submission_data:
        # print(data)
        submission.append(data["answer"])

    submission = np.array(submission)
    np.save(submission_file, submission)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--result-upload-file")
    parser.add_argument("--submission-file")
    args = parser.parse_args() 
    main(args.result_upload_file, args.submission_file)