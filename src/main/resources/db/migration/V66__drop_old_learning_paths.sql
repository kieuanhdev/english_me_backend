-- Remove old learning_paths system (replaced by learning_units / CurriculumService).
-- LearningController, LearningService, LearningPath entity deleted from codebase.

-- Drop FK constraints still pointing at learning_paths (columns kept: entities
-- UserLevel.currentPathId / UserLessonProgress.pathId are plain String fields).
ALTER TABLE user_levels DROP CONSTRAINT IF EXISTS user_levels_current_path_id_fkey;
ALTER TABLE user_lesson_progress DROP CONSTRAINT IF EXISTS user_lesson_progress_path_id_fkey;

DROP TABLE IF EXISTS user_path_progress;
DROP TABLE IF EXISTS learning_path_activities;
DROP TABLE IF EXISTS learning_paths;
