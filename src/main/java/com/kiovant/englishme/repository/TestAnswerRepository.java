package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Question;
import com.kiovant.englishme.entity.TestAnswer;
import com.kiovant.englishme.entity.TestSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TestAnswerRepository extends JpaRepository<TestAnswer, UUID> {

    List<TestAnswer> findByTestSession(TestSession testSession);

    Optional<TestAnswer> findByTestSessionAndQuestion(TestSession testSession, Question question);

    long countByTestSession(TestSession testSession);
}
