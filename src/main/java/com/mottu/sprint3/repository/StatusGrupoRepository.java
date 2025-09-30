package com.mottu.sprint3.repository;

import com.mottu.sprint3.model.StatusGrupo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StatusGrupoRepository extends JpaRepository<StatusGrupo, Long> {
}