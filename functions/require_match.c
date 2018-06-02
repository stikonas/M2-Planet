/* Copyright (C) 2016 Jeremiah Orians
 * This file is part of stage0.
 *
 * stage0 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * stage0 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with stage0.  If not, see <http://www.gnu.org/licenses/>.
 */
#include "../cc.h"
char* numerate_number(int a);

void line_error()
{
	file_print("In file: ", stderr);
	file_print(global_token->filename, stderr);
	file_print(" On line: ", stderr);
	file_print(numerate_number(global_token->linenumber), stderr);
}

void require_match(char* message, char* required)
{
	if(!match(global_token->s, required))
	{
		file_print(message, stderr);
		line_error();
		exit(EXIT_FAILURE);
	}
	global_token = global_token->next;
}