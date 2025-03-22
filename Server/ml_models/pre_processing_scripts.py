import os
import pandas as pd

# Define the base path of the dataset
base_path = r'C:\Programming\ml_models\Fall_UP_Dataset\UP_Fall_Detection_Dataset'

# Iterate through each subject folder
for subject in range(1, 5):  # Subject_01 to Subject_04
    subject_folder = f"Subject_{subject:02d}"
    subject_path = os.path.join(base_path, subject_folder)

    # Iterate through each activity folder (A01 to A11)
    for activity in range(1, 12):  # A01 to A11
        activity_folder = f"A{activity:02d}"
        activity_path = os.path.join(subject_path, activity_folder)

        # Iterate through each CSV file (S01_A01_T01, S01_A01_T02, S01_A01_T03)
        for time_point in range(1, 4):  # T01 to T03
            csv_filename = f"S{subject:02d}_A{activity:02d}_T{time_point:02d}.csv"
            csv_path = os.path.join(activity_path, csv_filename)

            if os.path.exists(csv_path):  # Check if the file exists
                # Load the CSV into a pandas DataFrame
                df = pd.read_csv(csv_path)

                # Select only the required columns
                columns_to_keep = ['TIME', 'PCKT_ACC_X', 'PCKT_ACC_Y', 'PCKT_ACC_Z']
                df = df[columns_to_keep]

                # Save the changes back to the same CSV file
                df.to_csv(csv_path, index=False)

                print(f"Processed {csv_filename}")

print("Processing complete!")
