

import React from 'react'
import './DataTable.css'

const DataTable = ({ 
  columns, 
  data, 
  loading, 
  onEdit, 
  onDelete, 
  onView,
  actions = ['edit', 'delete'] // تحديد الأافعال المتاحة
}) => {
  if (loading) {
    return <div className="loading">جاري التحميل...</div>;
  }

  return (
    <div className="data-table-container">
      <table className="data-table">
        <thead>
          <tr>
            {columns.map((column) => (
              <th key={column.key}>{column.title}</th>
            ))}
            {(actions.includes('edit') || actions.includes('delete') || actions.includes('view')) && (
              <th>الإجراءات</th>
            )}
          </tr>
        </thead>
        <tbody>
          {data && data.length > 0 ? (
            data.map((item, index) => (
              <tr key={item.id || index}>
                {columns.map((column) => (
                  <td key={column.key}>
                    {column.render ? column.render(item[column.key], item) : item[column.key]}
                  </td>
                ))}
                <td className="actions-cell">
                  {actions.includes('view') && onView && (
                    <button 
                      className="btn-view"
                      onClick={() => onView(item)}
                      title="عرض"
                    >
                      👁️
                    </button>
                  )}
                  {actions.includes('edit') && onEdit && (
                    <button 
                      className="btn-edit"
                      onClick={() => onEdit(item)}
                      title="تعديل"
                    >
                      ✏️
                    </button>
                  )}
                  {actions.includes('delete') && onDelete && (
                    <button 
                      className="btn-delete"
                      onClick={() => onDelete(item)}
                      title="حذف"
                    >
                      🗑️
                    </button>
                  )}
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan={columns.length + 1} className="no-data">
                لا توجد بيانات
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
};

export default DataTable