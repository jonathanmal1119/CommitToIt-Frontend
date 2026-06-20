# CommitToIt

CommitToIt is a productivity-focused task tracking application designed to help users stay consistent and motivated. The app combines task management with a reward-based system, encouraging users to complete tasks and earn points that can be redeemed for custom rewards.

## Features

* Create, update, and delete tasks
* Track task completion progress
* Earn points for completing tasks
* Redeem points for user-defined rewards
* User-based task storage and management
* Fast and responsive frontend built in Swift
* Backend powered by an Express API

## Concept

The core idea behind CommitToIt is simple:

The more tasks you complete, the more points you earn.

Users can define their own rewards (e.g., "Watch a movie", "Order food"), making the system personalized and motivating. This creates a gamified productivity loop that reinforces consistency and discipline.

## Tech Stack

### Frontend

* Swift (iOS application)
* Handles UI, user interaction, and API communication

### Backend

* Node.js
* Express.js
* REST API for managing users and tasks

### Database

* Stores user data, tasks, and reward points
* MySQL Database for its relational structure

## How It Works

1. User creates tasks in the app
2. Tasks are sent to the backend and stored in the database
3. When a task is completed:
   * It is marked as complete
   * Points are awarded to the user
4. Users can spend accumulated points on rewards they have defined


## Project Structure

```
CommitToIt-Frontend/
│── src/              # Frontend source files
│── components/       # UI components
│── services/         # API calls
│── assets/           # Images and static files
│── package.json      # Dependencies and scripts
```

(Adjust this if your structure differs)

## API Overview

The backend exposes endpoints such as:

* GET /tasks → Fetch user tasks
* POST /tasks → Create a new task
* PUT /tasks/:id → Update task status
* DELETE /tasks/:id → Remove a task

## Future Improvements

* Notifications and reminders
* Analytics dashboard (task trends, streaks)
* Social features or shared challenges
* Cloud synchronization across devices

## Inspiration

CommitToIt is inspired by the idea that productivity should feel rewarding, not exhausting. By turning daily tasks into a point-based system, users stay engaged and motivated over time.
