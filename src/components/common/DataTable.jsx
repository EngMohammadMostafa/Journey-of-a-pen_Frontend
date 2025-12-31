

import React from 'react'
import './DataTable.css'

const DataTable = ({ 
  columns, 
  data, 
  loading, 
  
}) => {
  if (loading) {
    return <div className="loading"> Loading...</div>;
  }

  return (
    <div className="data-table-container">
      <table className="data-table">
        <thead>
          <tr>
            {columns.map((column) => (
              <th key={column.key}>{column.title}</th>
            ))}
           
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
            
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan={columns.length + 1} className="no-data">
              No data available 
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
};

export default DataTable