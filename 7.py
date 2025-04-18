from dataclasses import dataclass
import random
from enum import Enum

class Number(Enum):
    ONE = 1
    TWO = 2
    THREE = 3

class Shape(Enum):
    DIAMOND = 'diamond'
    SQUIGGLE = 'squiggle'
    OVAL = 'oval'

class Shading(Enum):
    SOLID = 'solid'
    STRIPED = 'striped'
    OPEN = 'open'

class Color(Enum):
    RED = 'red'
    GREEN = 'green'
    PURPLE = 'purple'

@dataclass(frozen=True)
class Card:
    number: Number
    shape: Shape
    shading: Shading
    color: Color

    def get_tuple(self):
        return (self.number, self.shape, self.shading, self.color)
    
    def __repr__(self):
        return (f"Card(number={self.number.value}, "
                f"shape={self.shape.value}, "
                f"shading={self.shading.value}, "
                f"color={self.color.value})")

class Deck:
    def __init__(self):
        self.cards = [Card(n, s, sh, c)
                      for n in Number for s in Shape for sh in Shading for c in Color]
        self.shuffle()

    def shuffle(self):
        random.shuffle(self.cards)

    def draw(self, count=3):
        return [self.cards.pop() for _ in range(count)] if len(self.cards) >= count else []

def is_set(cards):
    features = list(zip(*(c.get_tuple() for c in cards)))
    return all(len(set(f)) == 1 or len(set(f)) == 3 for f in features)

def main():
    deck = Deck()

    while (cur_cards := deck.draw(3)):
        if is_set(cur_cards):
            print(f'Set found. {cur_cards}')
            return True

    print('No set found. Deck is empty')
    return False

if __name__ == '__main__':
    main()
