/*
 *    OpenRDK : OpenSource Robot Development Kit
 *    Copyright (C) 2007, 2008  Daniele Calisi, Andrea Censi (<first_name>.<last_name>@dis.uniroma1.it)
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef RDK2_SESSION_EXCEPTIONS
#define RDK2_SESSION_EXCEPTIONS

#include <exception>
#include <stdexcept>

/*
 * This file is a duplicate of ../repository/session.h
 *
 * Please refer to that for doxygen comments.
 */

#define DECLARE_EXCEPTION(SUB, SUPER) \
	struct SUB: public SUPER { \
		explicit SUB(const std::string&e):SUPER(e) { } \
}; 

namespace RDK2 {

DECLARE_EXCEPTION(RdkException,          std::runtime_error);
DECLARE_EXCEPTION(SessionException,	 RdkException);
DECLARE_EXCEPTION(NoSuchProperty,	 SessionException);
DECLARE_EXCEPTION(ValueNotSet,		 SessionException);
DECLARE_EXCEPTION(WrongType,		 SessionException);
DECLARE_EXCEPTION(InvalidOperation,	 SessionException);
DECLARE_EXCEPTION(MalformedUrlException, RdkException);

/** Base class for exception generated by the serialization. */
DECLARE_EXCEPTION(SerializationException, RdkException);

DECLARE_EXCEPTION(WritingException, SerializationException);
DECLARE_EXCEPTION(ReadingException, SerializationException);

/** During writing, bad order of calls to the Writer. (or a programming error in the Writer itself) */
DECLARE_EXCEPTION(WritingStackException, WritingException);

} // namespace

#endif