// Quick script to add categories
// Run this in your browser console on the admin products page

const categories = [
  { name: 'TEES', slug: 'tees', description: 'T-Shirts and tops collection' },
  { name: 'BOTTOMS', slug: 'bottoms', description: 'Pants, shorts and bottoms collection' },
  { name: 'ESSENTIALS', slug: 'essentials', description: 'Basic essentials and everyday wear' },
  { name: 'ACCESSORIES', slug: 'accessories', description: 'Accessories and complementary items' },
  { name: 'OUTERWEAR', slug: 'outerwear', description: 'Jackets, hoodies and outerwear collection' }
];

async function addCategories() {
  for (const category of categories) {
    try {
      const response = await fetch('/api/categories', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(category)
      });
      
      if (response.ok) {
        console.log(`✅ Added category: ${category.name}`);
      } else {
        console.log(`⚠️ Category ${category.name} might already exist`);
      }
    } catch (error) {
      console.error(`❌ Error adding ${category.name}:`, error);
    }
  }
  
  console.log('🎉 Categories setup complete! Refresh the page.');
}

// Run the function
addCategories();
