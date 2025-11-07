import React from 'react'

const SearchBar = ({ placeholder, value, onChange, onSearch }) => {
  const handleSubmit = (e) => {
    e.preventDefault()
    if (onSearch) {
      onSearch(value)
    }
  }

  return (
    <form onSubmit={handleSubmit} style={{
      position: 'relative',
      width: '100%',
      maxWidth: '400px'
    }}>
      <input
        type="text"
        placeholder={placeholder || "ابحث..."}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        style={{
          width: '100%',
          padding: '12px 45px 12px 16px',
          border: '1px solid #ddd',
          borderRadius: '25px',
          fontSize: '14px',
          outline: 'none',
          transition: 'border-color 0.3s, box-shadow 0.3s',
          background: 'white',
          fontFamily: 'Arial, sans-serif'
        }}
        onFocus={(e) => {
          e.target.style.borderColor = '#007bff'
          e.target.style.boxShadow = '0 0 0 2px rgba(0, 123, 255, 0.25)'
        }}
        onBlur={(e) => {
          e.target.style.borderColor = '#ddd'
          e.target.style.boxShadow = 'none'
        }}
      />
      <button
        type="submit"
        style={{
          position: 'absolute',
          left: '15px',
          top: '50%',
          transform: 'translateY(-50%)',
          background: 'none',
          border: 'none',
          color: '#6c757d',
          cursor: 'pointer',
          padding: '5px',
          fontSize: '16px'
        }}
        onMouseEnter={(e) => {
          e.target.style.color = '#007bff'
        }}
        onMouseLeave={(e) => {
          e.target.style.color = '#6c757d'
        }}
      >
        🔍
      </button>
    </form>
  )
}

export default SearchBar