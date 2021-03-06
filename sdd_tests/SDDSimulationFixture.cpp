/**********************************************************************
*  Copyright (c) 2008-2010, Alliance for Sustainable Energy.  
*  All rights reserved.
*  
*  This library is free software; you can redistribute it and/or
*  modify it under the terms of the GNU Lesser General Public
*  License as published by the Free Software Foundation; either
*  version 2.1 of the License, or (at your option) any later version.
*  
*  This library is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*  Lesser General Public License for more details.
*  
*  You should have received a copy of the GNU Lesser General Public
*  License along with this library; if not, write to the Free Software
*  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
**********************************************************************/

#include <sdd_tests/SDDSimulationFixture.hpp>
//#include <model/TimeDependentValuation.hpp>
#include <utilities/filetypes/TimeDependentValuationFile.hpp>
#include <utilities/sql/SqlFile.hpp>
#include <utilities/core/FileLogSink.hpp>
#include <utilities/core/Path.hpp>

void SDDSimulationFixture::SetUp() {}

void SDDSimulationFixture::TearDown() {}

void SDDSimulationFixture::SetUpTestCase() {
  // set up logging
  logFile = openstudio::FileLogSink(openstudio::toPath("./SDDTestFixture.log"));
  logFile->setLogLevel(Debug);

}

void SDDSimulationFixture::TearDownTestCase() {}

boost::optional<openstudio::FileLogSink> SDDSimulationFixture::logFile;

