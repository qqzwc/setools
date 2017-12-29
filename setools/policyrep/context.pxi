# Copyright 2014-2015, Tresys Technology, LLC
# Copyright 2016-2017, Chris PeBenito <pebenito@ieee.org>
#
# This file is part of SETools.
#
# SETools is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 2.1 of
# the License, or (at your option) any later version.
#
# SETools is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with SETools.  If not, see
# <http://www.gnu.org/licenses/>.
#

cdef inline Context context_factory(SELinuxPolicy policy, const qpol_context_t *symbol):
    """Factory function for creating Context objects."""
    r = Context()
    r.policy = policy
    r.handle = symbol
    return r


cdef class Context(PolicySymbol):

    """A SELinux security context/security attribute."""

    cdef const qpol_context_t *handle

    def __str__(self):
        try:
            return "{0.user}:{0.role}:{0.type_}:{0.range_}".format(self)
        except MLSDisabled:
            return "{0.user}:{0.role}:{0.type_}".format(self)

    def _eq(self, Context other):
        """Low-level equality check (C pointers)."""
        return self.handle == other.handle

    @property
    def user(self):
        """The user portion of the context."""
        cdef const qpol_user_t *u
        if qpol_context_get_user(self.policy.handle, self.handle, &u):
            raise RuntimeError("Could not get user from context")

        return user_factory(self.policy, u)

    @property
    def role(self):
        """The role portion of the context."""
        cdef const qpol_role_t *r
        if qpol_context_get_role(self.policy.handle, self.handle, &r):
            raise RuntimeError("Could not get role from context")

        return role_factory(self.policy, r)

    @property
    def type_(self):
        """The type portion of the context."""
        cdef const qpol_type_t *t
        if qpol_context_get_type(self.policy.handle, self.handle, &t):
            raise RuntimeError("Could not get type from context")

        return type_factory(self.policy, t, False)

    @property
    def range_(self):
        """The MLS range of the context."""
        pass
        cdef const qpol_mls_range_t *r
        if qpol_context_get_range(self.policy.handle, self.handle, &r):
            raise RuntimeError("Could not get range from context")

        return range_factory(self.policy, r)

    def statement(self):
        raise NoStatement
