import cv2
import tkinter as tk
from tkinter import filedialog, messagebox
from PIL import Image, ImageTk
import numpy as np
import matplotlib.pyplot as plt
import time
import csv
import os

class VideoFrameGrabber:
    def __init__(self, root):
        self.root = root
        self.root.title("Video Frame Grabber")
        self.vid = None
        self.frame = None
        self.total_frames = 0
        self.current_frame = 0
        self.roi_start = None
        self.roi_end = None
        self.roi_values = []

        # Canvas for video, initialized with default size.
        self.canvas = tk.Canvas(root, width=500, height=500)
        self.canvas.pack()

        # Frame slider
        self.slider = tk.Scale(root, from_=0, to=1, orient='horizontal', length=500, command=self.get_frame)
        self.slider.pack(fill='x')

        # Buttons
        self.btn_load = tk.Button(root, text="Load Video", command=self.load_video)
        self.btn_load.pack(fill='x')

        self.btn_label_roi = tk.Button(root, text="Label ROI", command=self.label_roi)
        self.btn_label_roi.pack(fill='x')

        # Call update function to start the loop for video frame reading
        self.update()

    def load_video(self):
        self.filename = filedialog.askopenfilename(title="Select a video file", filetypes=(("MP4 files", "*.mp4"), ("All files", "*.*")))
        self.vid = cv2.VideoCapture(self.filename)
        self.total_frames = int(self.vid.get(cv2.CAP_PROP_FRAME_COUNT))
        self.slider.config(to=self.total_frames)
        self.get_frame(0)  # Initialize with first frame

        # Resize the canvas to fit the video
        width = self.vid.get(cv2.CAP_PROP_FRAME_WIDTH)
        height = self.vid.get(cv2.CAP_PROP_FRAME_HEIGHT)
        self.canvas.config(width=int(width), height=int(height))

    def label_roi(self):
        if self.frame is not None:
            # Reset the ROI and ROI values
            self.roi_start = None
            self.roi_end = None
            self.roi_values = []

            # Bind mouse events
            self.canvas.bind("<ButtonPress-1>", self.on_mouse_press)
            self.canvas.bind("<B1-Motion>", self.on_mouse_drag)
            self.canvas.bind("<ButtonRelease-1>", self.on_mouse_release)

        else:
            messagebox.showwarning("Warning", "No frame to label. Please load a video.")

    def on_mouse_press(self, event):
        self.roi_start = (event.x, event.y)

    def on_mouse_drag(self, event):
        self.roi_end = (event.x, event.y)
        self.draw_roi()

    def on_mouse_release(self, event):
        self.roi_end = (event.x, event.y)
        self.draw_roi()
        self.canvas.unbind("<ButtonPress-1>")
        self.canvas.unbind("<B1-Motion>")
        self.canvas.unbind("<ButtonRelease-1>")

        # Calculate average red value in ROI for each frame
        if self.vid is not None and self.roi_start is not None and self.roi_end is not None:
            self.vid.set(cv2.CAP_PROP_POS_FRAMES, 0)
            ret, frame = self.vid.read()
            frame_count = 0
            start_time = time.time()

            while ret:
                '''
				# v2
				# It could be optimized if we do red-gray substraction for each roi and not_roi, and then the roi - not_roi substrantion
                roi = frame[self.roi_start[1]:self.roi_end[1], self.roi_start[0]:self.roi_end[0]]
                roi_red = roi[:, :, 2]
                roi_gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
                # substract gray
                r_diff = roi_red - roi_gray
				
                # Get the no roi
                no_roi = frame[200:-200, 200:-200]
                no_roi_red = no_roi[:, :, 2]
                no_roi_gray = cv2.cvtColor(no_roi, cv2.COLOR_BGR2GRAY)
                # substract gray
                #no_r_diff = np.abs(no_roi_red - no_roi_gray)
                no_r_diff = no_roi_red - no_roi_gray
                
                r_diff = r_diff.ravel()
                no_r_diff = no_r_diff.ravel()
                #print(no_r_diff.shape)
                #exit()
                avg_red = np.median(r_diff) - np.median(no_r_diff)
                cv2.imshow('Image',no_roi) 
                print(avg_red)
                exit()
                '''
                
				
				
				
                '''
				# v1
				# Get red color form the frame
                r = frame[:, :, 2]
				# Substract gray
                gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                r_diff = r - gray

                # Get the roi and non-roi
                roi_frame = r_diff[self.roi_start[1]:self.roi_end[1], self.roi_start[0]:self.roi_end[0]]
                #not_roi_frame = r_diff[100:150, 100:150]
                not_roi_frame = r_diff

				
                red_values_roi = roi_frame.ravel()
                #print (np.mean(red_values))
                #print(np.mean(red_values))
                #exit()
                red_values_not_roi = not_roi_frame.ravel()
                avg_red = np.median(red_values_roi) - np.median(red_values_not_roi)
                print(avg_red)
                print(red_values_roi)
                print(red_values_not_roi)
                exit()
                '''
                
                # v3 - works and it's fast
                '''
                roi = frame[self.roi_start[1]:self.roi_end[1], self.roi_start[0]:self.roi_end[0]]
                b,g,r = cv2.split(roi)
                k = np.zeros_like(b)
                r = cv2.merge([k,k,r])
                avg_red = np.mean(r.ravel()) 
                '''
                
                
                # v4 - not good
                '''
                roi = frame[self.roi_start[1]:self.roi_end[1], self.roi_start[0]:self.roi_end[0]]
                b,g,r = cv2.split(roi)
                gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
                diff_red = r - gray
                avg_red = np.mean(diff_red.ravel()) 
                '''
                
                # v5 - works
                '''
                roi = frame[self.roi_start[1]:self.roi_end[1], self.roi_start[0]:self.roi_end[0]]
                b,g,r = cv2.split(roi)
                k = np.zeros_like(b)
                r_roi = cv2.merge([k,k,r])
                # no roi
                no_roi = frame[200:-200, 200:-200]
                b,g,r = cv2.split(no_roi)
                k = np.zeros_like(b)
                r_no_roi = cv2.merge([k,k,r])
                diff_r = np.mean(r_roi.ravel()) - np.mean(r_no_roi.ravel())
                '''
                
                # v6 - works
                # same that matlab script
                # convert to red and subtract gray
                b,g,r = cv2.split(frame)
                gray =  cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                diff_im = cv2.subtract(r,gray)
                roi = diff_im[self.roi_start[1]:self.roi_end[1], self.roi_start[0]:self.roi_end[0]]
                intensity_roi = roi
                intensity_no_roi = diff_im
                avg_red = np.mean(intensity_roi.ravel()) - np.mean(intensity_no_roi.ravel())
                #avg_red = np.mean(red_values)
                
                
                
                self.roi_values.append(avg_red)

                ret, frame = self.vid.read()
                frame_count += 1

                if frame_count % 10000 == 0:
                    elapsed_time = time.time() - start_time
                    print(f"Time spent: {elapsed_time * 1000:.2f} ms | Current Frame: {frame_count} / {self.total_frames}")

            # Plot time series data
            frame_numbers = np.arange(frame_count)
            plt.plot(frame_numbers, self.roi_values)
            plt.xlabel('Frame Number')
            plt.ylabel('Average Red Value')
            plt.title('ROI Average Red Value over Time')
            plt.show()

            # # Save time series data as NumPy array
            # data_array = np.array(self.roi_values)
            # np.save('led_event.npy', data_array)
			
			# Save time series data as CSV
			# Extract the filename from the path
            directory = os.path.dirname(self.filename)
            filename = os.path.basename(self.filename)

			# Change the file extension to .csv
            csv_filename = os.path.join(directory, os.path.splitext(filename)[0] + '_LED_event.csv')
            with open(csv_filename, 'w', newline='') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(self.roi_values)

    def draw_roi(self):
        self.canvas.delete("roi_rectangle")
        if self.roi_start is not None and self.roi_end is not None:
            self.canvas.create_rectangle(self.roi_start[0], self.roi_start[1], self.roi_end[0], self.roi_end[1],
                                         outline="green", width=2, tags="roi_rectangle")

    def get_frame(self, current_frame):
        self.current_frame = int(current_frame)
        if self.vid is not None:
            self.vid.set(cv2.CAP_PROP_POS_FRAMES, self.current_frame)
            _, self.frame = self.vid.read()
            self.frame = cv2.cvtColor(self.frame, cv2.COLOR_BGR2RGB)
            self.photo = ImageTk.PhotoImage(image=Image.fromarray(self.frame))
            self.canvas.create_image(0, 0, image=self.photo, anchor=tk.NW)

    def update(self):
        self.slider.set(self.current_frame)
        self.root.after(1, self.update)  # Call update function after 1 ms

# Create a window and pass it to the VideoFrameGrabber object
root = tk.Tk()
app = VideoFrameGrabber(root)
root.mainloop()
