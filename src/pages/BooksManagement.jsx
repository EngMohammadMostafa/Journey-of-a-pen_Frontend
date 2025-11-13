import React, { useState } from 'react'
import '../styles/global.css'
import '../styles/BooksManagement.css'

const BooksManagement = () => {
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(false);

  // الأزرار الأساسية
  const handleAddBook = () => {
    alert('زر إضافة كتاب جديد');
  };

  const handleEditBook = () => {
    alert('زر تعديل كتاب');
  };

  const handleDeleteBook = () => {
    alert('زر حذف كتاب');
  };

  return (
    <div className="books-management">
      <div className="page-header">
        <h1>إدارة الكتب</h1>
      </div>

      <div className="buttons-container">
        <button className="btn-primary" onClick={handleAddBook}>+ إضافة كتاب</button>
        <button className="btn-secondary" onClick={handleEditBook}>تعديل كتاب</button>
        <button className="btn-danger" onClick={handleDeleteBook}>حذف كتاب</button>
      </div>
    </div>
  );
};

export default BooksManagement
