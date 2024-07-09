/**
 * @jest-environment jsdom
 */

const classie = require('../js/classie'); // Adjust the path as necessary

describe('classie', () => {
  let element;

  beforeEach(() => {
    // Set up our document body
    document.body.innerHTML = '<div id="test-element" class="initial-class"></div>';
    element = document.getElementById('test-element');
  });

  test('should add a class to an element', () => {
    classie.addClass(element, 'new-class');
    expect(element.classList.contains('new-class')).toBe(true);
  });

  test('should remove a class from an element', () => {
    classie.addClass(element, 'remove-class');
    classie.removeClass(element, 'remove-class');
    expect(element.classList.contains('remove-class')).toBe(false);
  });

  test('should check if an element has a class', () => {
    classie.addClass(element, 'check-class');
    expect(classie.has(element, 'check-class')).toBe(true);
  });

  test('should toggle a class on an element', () => {
    classie.toggle(element, 'toggle-class');
    expect(element.classList.contains('toggle-class')).toBe(true);
    classie.toggle(element, 'toggle-class');
    expect(element.classList.contains('toggle-class')).toBe(false);
  });
});
