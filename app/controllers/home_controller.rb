class HomeController < ApplicationController

  def index

  end

  def import
    if params[:file].present?
      begin
        ladies = []
        gents = []
        others = []
        f = File.new(params[:file].path)
        xlsx = Roo::Spreadsheet.open(f)
        xlsx.default_sheet = xlsx.sheets.first
        if xlsx.sheets.count == 1
          # row attributes - "NO, NAME, GEN, AGE, CELL, EMAIL, CENTER"
          header_column = {no: "NO", name: "NAME", gender: "GEN", age: "AGE", cell: "CELL", email: "EMAIL", center: "CENTER"}

          xlsx.each_with_index(header_column) do |row, index|
            # {:no=>1, :name=>"AANYA HARSH MEHTA", :gender=>"Female", :age=>nil, :cell=>9892623541, :email=>"Harshmehta24@gmail.com", :center=>"Mumbai"}
            next if index == 0
            # blank row check
            if check_row_is_blank(row)
              next
            elsif row[:gender] == 'Female' || row[:gender] == 'female' || row[:gender] == 'FEMALE' || row[:gender] == 'F' || row[:gender] == 'f'
              ladies << row
            elsif row[:gender] == 'Male' || row[:gender] == 'male' || row[:gender] == 'MALE' || row[:gender] == 'M' || row[:gender] == 'm'
              gents << row
            else
              others << row
            end
          end
        end


        ladies.sort_by!{|hsh| hsh[:age].to_i}
        gents.sort_by!{|hsh| hsh[:age].to_i}
        others.sort_by!{|hsh| hsh[:age].to_i}
        ladies.reverse!
        gents.reverse!
        others.reverse!

        oag_conditions = {
            1 => [3, 'l'],
            2 => [3, 'l'],
            3 => [3,'l'],
            4 => [3, 'g'],
            5 => [2, 'g'],
            6 => [2, 'g'],
            11 => [3, 'g'],
            16 => [3, 'g'],
            19 => [3, 'l'],
            20 => [3, 'l'],
            21 => [3, 'l'],
            22 => [3, 'l'],
            23 => [2, 'l'],
            25 => [2, 'g']
        }

        nag_conditions = {
            37 => [3, 'l'], #ac
            38 => [3, 'l'], #ac
            39 => [3, 'l'],
            40 => [3, 'l'],
            41 => [2, 'l'],
            42 => [2, 'l'],
            43 => [3, 'g'],
            45 => [3, 'g'], #ac
            46 => [3, 'g'], #ac
            47 => [3, 'g'], #ac
            48 => [3, 'g'], #ac
            49 => [3, 'l'],
            50 => [2, 'l'],
            51 => [2, 'l'],
            52 => [2, 'l'],
            53 => [2, 'l'],
            54 => [2, 'g'],
            55 => [2, 'g'],
            57 => [2, 'g'],
            58 => [2, 'g'],
            59 => [2, 'g'],
            60 => [2, 'g']
        }
        count  = 0
        @oag_allocation = {}
        @nag_allocation = {}
        total = (ladies.length if ladies.present?) + (gents.length if gents.present?) + (others.length if others.present?)

        if total <= 52
          oag_conditions.each do |room, condition|

            if count <= total
              roomiez = ladies[0..condition[0]] if condition[1] == 'l'
              roomiez = gents[0..condition[0]] if condition[1] == 'g'

              @oag_allocation[room] = roomiez
              condition[0].times {
                ladies.delete_at(0)
                count += 1
              } if condition[1] == 'l'

              condition[0].times {
                gents.delete_at(0)
                count += 1
              } if condition == 'g'
            else
              break
            end

          end

        end

        if total > 52
          nag_conditions.each do |room, condition|
            roomiez = ladies[0..condition[0]] if condition[1] == 'l'
            roomiez = gents[0..condition[0]] if condition[1] == 'g'

            @nag_allocation[room] = roomiez
            condition[0].times { ladies.delete_at(0) } if condition[1] == 'l'
            condition[0].times { gents.delete_at(0) } if condition == 'g'
          end
        end
        render 'result'
      end
    end
  end

  private

  def check_row_is_blank(row)
    row_blank = true
    row.each do |k, v|
      unless v.blank?
        row_blank = false
        break
      end
    end
    return row_blank
  end

end
