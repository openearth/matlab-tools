#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
#
#       Laan 1914, nr 35
#       3818 EX Amersfoort
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
class GlobalWealth(object):
    def __init__(self):
        self._global_wealth = 10.0
        self._observers = []

    def get_wealth(self):
        return self._global_wealth

    def set_wealth(self, value):
        self._global_wealth = value
        for callback in self._observers:
            print 'anouncing change'
            callback(self._global_wealth)

    global_wealth = property(get_wealth, set_wealth)

    def bind_to(self, callback):
        print 'bound'
        self._observers.append(callback)


class Person(object):
    def __init__(self, data):
        self.wealth = 1.0
        self.data = data
        self.data.bind_to(self.update_how_happy)
        self.happiness = self.wealth / self.data.global_wealth

    def update_how_happy(self, global_wealth):
        self.happiness = self.wealth / global_wealth



data = GlobalWealth()
p = Person(data)
print p.happiness
data.global_wealth = 1.0
print p.happiness