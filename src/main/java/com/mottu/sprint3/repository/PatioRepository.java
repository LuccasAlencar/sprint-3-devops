package com.mottu.sprint3.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.mottu.sprint3.model.Patio;

@Repository
public interface PatioRepository extends JpaRepository<Patio, Long> {
}