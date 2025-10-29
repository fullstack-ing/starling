/**
 * Dropdown Component
 *
 * Handles <el-dropdown> and <el-menu> elements for navigation dropdowns.
 * Progressive enhancement - works with keyboard and mouse.
 */

/**
 * Initializes all dropdowns on the page
 */
export function initDropdowns() {
  const dropdowns = document.querySelectorAll("el-dropdown");
  console.log(`Found ${dropdowns.length} dropdown(s)`);
  dropdowns.forEach((dropdown) => enhanceDropdown(dropdown));
}

/**
 * Enhances a single dropdown element
 * @param {HTMLElement} dropdown - The el-dropdown element
 */
function enhanceDropdown(dropdown) {
  const button = dropdown.querySelector("button");
  const menu = dropdown.querySelector("el-menu");

  console.log("Enhancing dropdown:", { button, menu, dropdown });

  if (!button || !menu) {
    console.warn("Dropdown missing button or menu", { dropdown, button, menu });
    return;
  }

  console.log("Dropdown enhanced successfully");

  // Set initial ARIA attributes
  button.setAttribute("aria-haspopup", "true");
  button.setAttribute("aria-expanded", "false");
  menu.setAttribute("role", "menu");
  menu.setAttribute("data-closed", "");

  // Toggle dropdown on button click
  button.addEventListener("click", (e) => {
    console.log("Dropdown button clicked");
    e.stopPropagation();
    const isOpen = button.getAttribute("aria-expanded") === "true";

    if (isOpen) {
      console.log("Closing dropdown");
      closeDropdown(button, menu);
    } else {
      console.log("Opening dropdown");
      // Close any other open dropdowns first
      closeAllDropdowns();
      openDropdown(button, menu);
    }
  });

  // Close dropdown when clicking outside
  document.addEventListener("click", (e) => {
    if (!dropdown.contains(e.target)) {
      closeDropdown(button, menu);
    }
  });

  // Close dropdown on Escape key
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      const isOpen = button.getAttribute("aria-expanded") === "true";
      if (isOpen) {
        closeDropdown(button, menu);
        button.focus();
      }
    }
  });

  // Reposition menu on window resize if open
  window.addEventListener("resize", () => {
    const isOpen = button.getAttribute("aria-expanded") === "true";
    if (isOpen) {
      positionMenu(button, menu);
    }
  });

  // Handle keyboard navigation within menu
  menu.addEventListener("keydown", (e) => {
    const menuItems = Array.from(menu.querySelectorAll("a, button"));
    const currentIndex = menuItems.indexOf(document.activeElement);

    switch (e.key) {
      case "ArrowDown":
        e.preventDefault();
        const nextIndex = (currentIndex + 1) % menuItems.length;
        menuItems[nextIndex]?.focus();
        break;
      case "ArrowUp":
        e.preventDefault();
        const prevIndex = currentIndex <= 0 ? menuItems.length - 1 : currentIndex - 1;
        menuItems[prevIndex]?.focus();
        break;
      case "Home":
        e.preventDefault();
        menuItems[0]?.focus();
        break;
      case "End":
        e.preventDefault();
        menuItems[menuItems.length - 1]?.focus();
        break;
    }
  });
}

/**
 * Opens a dropdown menu
 */
function openDropdown(button, menu) {
  button.setAttribute("aria-expanded", "true");
  menu.removeAttribute("hidden");

  // Position the menu intelligently based on available space
  positionMenu(button, menu);

  // Trigger animation by removing data-closed on next frame
  requestAnimationFrame(() => {
    menu.removeAttribute("data-closed");
  });

  // Focus first menu item after animation
  setTimeout(() => {
    const firstItem = menu.querySelector("a, button");
    firstItem?.focus();
  }, 10);
}

/**
 * Positions a dropdown menu intelligently based on viewport space
 * @param {HTMLElement} button - The dropdown button
 * @param {HTMLElement} menu - The dropdown menu
 */
function positionMenu(button, menu) {
  // Get button position
  const buttonRect = button.getBoundingClientRect();

  // Get viewport dimensions
  const viewportWidth = window.innerWidth;
  const viewportHeight = window.innerHeight;

  // Get menu dimensions (it's visible but may be scaled down)
  const menuRect = menu.getBoundingClientRect();
  const menuWidth = menuRect.width || 192; // 12rem default
  const menuHeight = menuRect.height || 200; // estimate

  // Calculate space on each side
  const spaceRight = viewportWidth - buttonRect.right;
  const spaceLeft = buttonRect.left;
  const spaceBottom = viewportHeight - buttonRect.bottom;
  const spaceTop = buttonRect.top;

  // Reset positioning classes
  menu.classList.remove('menu-left', 'menu-right', 'menu-top', 'menu-bottom');

  // Horizontal positioning
  // Check if button is on the right side of viewport (profile dropdown scenario)
  const isRightSide = buttonRect.right > (viewportWidth / 2);

  if (isRightSide && spaceRight < menuWidth) {
    // Button on right side and not enough space: align menu's right edge with button's right edge
    menu.classList.add('menu-left');
    console.log('Positioning menu to left (right edge aligned)', { spaceRight, menuWidth, buttonRect });
  } else if (!isRightSide && spaceLeft < menuWidth) {
    // Button on left side and not enough space: align menu's left edge with button's left edge
    menu.classList.add('menu-right');
    console.log('Positioning menu to right (left edge aligned)');
  } else if (isRightSide) {
    // Button on right side with enough space: default right alignment
    menu.classList.add('menu-left');
    console.log('Positioning menu to left (default for right side)', { spaceRight, menuWidth });
  } else {
    // Button on left side with enough space: default left alignment
    menu.classList.add('menu-right');
    console.log('Positioning menu to right (default for left side)');
  }

  // Vertical positioning
  // Default is below button, but flip to above if not enough space
  if (spaceBottom < menuHeight && spaceTop > menuHeight) {
    menu.classList.add('menu-top');
    console.log('Positioning menu above button');
  } else {
    menu.classList.add('menu-bottom');
    console.log('Positioning menu below button (default)');
  }
}

/**
 * Closes a dropdown menu
 */
function closeDropdown(button, menu) {
  button.setAttribute("aria-expanded", "false");
  menu.setAttribute("data-closed", "");

  // Wait for animation to complete before hiding
  setTimeout(() => {
    if (menu.hasAttribute("data-closed")) {
      menu.setAttribute("hidden", "");
    }
  }, 100); // Match transition duration
}

/**
 * Closes all open dropdowns
 */
function closeAllDropdowns() {
  const dropdowns = document.querySelectorAll("el-dropdown");
  dropdowns.forEach((dropdown) => {
    const button = dropdown.querySelector("button");
    const menu = dropdown.querySelector("el-menu");
    if (button && menu) {
      closeDropdown(button, menu);
    }
  });
}

/**
 * Observe DOM for new dropdowns (for LiveView patches)
 */
export function observeDropdowns() {
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      mutation.addedNodes.forEach((node) => {
        if (node.nodeType === 1) {
          if (node.tagName === "EL-DROPDOWN") {
            enhanceDropdown(node);
          }
          // Also check children
          const dropdowns = node.querySelectorAll?.("el-dropdown");
          dropdowns?.forEach(enhanceDropdown);
        }
      });
    });
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });

  return observer;
}

// Auto-initialize on DOMContentLoaded
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => {
    initDropdowns();
    observeDropdowns();
  });
} else {
  // DOM already loaded
  initDropdowns();
  observeDropdowns();
}
