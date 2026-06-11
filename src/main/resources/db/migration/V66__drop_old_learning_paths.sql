-- Remove old learning_paths system (replaced by learning_units / CurriculumService).
-- LearningController, LearningService, LearningPath entity deleted from codebase.

DROP TABLE IF EXISTS user_path_progress;
DROP TABLE IF EXISTS learning_path_activities;
DROP TABLE IF EXISTS learning_paths;
