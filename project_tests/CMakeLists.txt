SET( target_name project_tests )

SET( ${target_name}_src
  ProjectFixture.hpp
  ProjectFixture.cpp
  ProjectDatabaseProfiling_GTest.cpp
)

SET( ${target_name}_depends
 ${OPENSTUDIO_LIBS}
)

CREATE_TEST_TARGET( ${target_name} "${${target_name}_src}" "${${target_name}_depends}" )

ADD_DEPENDENCIES(${target_name}
  project_resources )

